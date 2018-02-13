param
(
    [string] $rgName,
    [string] $location,
    [string] $vhdUri,
    [string] $VMName,
    [PSCredential] $cred
)

# Create private key for WinRMS
$fullDnsName = "$VMName.$location.cloudapp.azure.com"
$tempPath = [System.IO.Path]::GetTempPath()
$privateKeyPath = Join-Path $tempPath "WinRM.pfx"
$privateKeyPasswordPlain = (New-Guid).ToString('n')
$privateKeyPassword = ConvertTo-SecureString -String $privateKeyPasswordPlain -AsPlainText -Force
$privateKey = New-SelfSignedCertificate -DnsName $fullDnsName -CertStoreLocation 'Cert:\CurrentUser\My'
Export-PfxCertificate -Cert $privateKey -FilePath $privateKeyPath -Password $privateKeyPassword -Force
Remove-Item "Cert:\CurrentUser\My\$($privateKey.Thumbprint)" -Force

# Store private key in Azure Key Vault
$args = @{
    VaultName = $VMName + 'KeyVault'
    ResourceGroupName = $rgName
    Location = $location
    EnabledForDeployment = $true
}
$keyVault = New-AzureRmKeyVault @args
Write-Output "Created Key Vault: $($keyVault.ResourceId)"

$privateKeyBytes = Get-Content $privateKeyPath -Encoding Byte
$privateKeyBase64 = [System.Convert]::ToBase64String($privateKeyBytes)
$privateKeyJson = @{
    data = $privateKeyBase64
    dataType = 'pfx'
    password = $privateKeyPasswordPlain
}
$privateKeyJson = ConvertTo-Json -InputObject $privateKeyJson
$privateKeyBytes = [System.Text.Encoding]::UTF8.GetBytes($privateKeyJson)
$privateKeyBase64 = [System.Convert]::ToBase64String($privateKeyBytes)
$privateKeySecret = ConvertTo-SecureString -String $privateKeyBase64 -AsPlainText -Force

$keyVaultKeyName = $VMName + '-WinRM'
$keyVaultWinRM = Set-AzureKeyVaultSecret -VaultName $keyVault.VaultName -Name $keyVaultKeyName -SecretValue $privateKeySecret
Write-Output "Added Key Vault key: $($keyVaultWinRM.Id)"

Remove-Item $privateKeyPath -Force

# Create a subnet configuration
$args = @{
    Name = $VMName + 'Subnet'
    AddressPrefix = '192.168.1.0/24'
}
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig @args

# Create a virtual network
$args = @{
    Name = $VMName + 'Net'
    ResourceGroupName = $rgName
    Location = $location
    AddressPrefix = '192.168.0.0/16'
    Subnet = $subnetConfig
}
$vnet = New-AzureRmVirtualNetwork @args
Write-Output "Created Virtual Network: $($vnet.Id)"

# Create a public IP address and specify a DNS name
$args = @{
    Name = $VMName + 'PublicIP'
    ResourceGroupName = $rgName
    Location = $location
    AllocationMethod = 'Dynamic'
    IdleTimeoutInMinutes = 4
}
$publicIP = New-AzureRmPublicIpAddress @args
Write-Output "Created Public IP: $($publicIP.Id)"

# Create an inbound network security group rule for port 5986 - WinRM: HTTPS
$args = @{
    Name = 'WinRM'
    Protocol = 'Tcp'
    Direction = 'Inbound'
    SourceAddressPrefix = '*'
    SourcePortRange = '*'
    DestinationAddressPrefix = '*'
    DestinationPortRange = 5986
    Access = 'Allow'
    Priority = 1001
}
$nsgRuleWRM = New-AzureRmNetworkSecurityRuleConfig @args

# Create a network security group
$args = @{
    Name = $VMName + 'NSG'
    ResourceGroupName = $rgName
    Location = $location
    SecurityRules = $nsgRuleWRM
}
$nsg = New-AzureRmNetworkSecurityGroup @args
Write-Output "Created Network Security Group: $($nsg.Id)"

# Create a virtual network card and associate with public IP address and NSG
$args = @{
    Name = $VMName + 'NIC'
    ResourceGroupName = $rgName
    Location = $location
    SubnetId = $vnet.Subnets[0].Id
    NetworkSecurityGroupId = $nsg.Id
    PublicIpAddressId = $publicIP.Id
}
$nic = New-AzureRmNetworkInterface @args
Write-Output "Created Network Interface: $($nic.Id)"

# Define the image created by Packer
$imageConfig = New-AzureRmImageConfig -Location $location
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType Windows -OsState Generalized -BlobUri $vhdUri
$imageName = $VMName + 'Image'
$image = New-AzureRmImage -ImageName $imageName -ResourceGroupName $rgName -Image $imageConfig
Write-Output "Created Image: $($image.Id)"

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName $VMName -VMSize 'Basic_A2'
$vmConfig = $vmConfig | Set-AzureRmVMOperatingSystem -Windows -ComputerName $VMName -Credential $cred -WinRMHttps -WinRMCertificateUrl $keyVaultWinRM.Id
$vmConfig = $vmConfig | Set-AzureRmVMSourceImage -Id $image.Id
$vmConfig = $vmConfig | Add-AzureRmVMSecret -SourceVaultId $keyVault.ResourceId -CertificateStore 'My' -CertificateUrl $keyVaultWinRM.Id
$vmConfig = $vmConfig | Add-AzureRmVMNetworkInterface -Id $nic.Id
$vmConfig = $vmConfig | Add-AzureRmVMDataDisk -DiskSizeInGB 64 -CreateOption Empty -Lun 0

New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vmConfig
$vm = Get-AzureRmVM -ResourceGroupName $rgName -Name $VMName
Write-Output "Created Virtual Machine: $($vm.Id)"

# Delete Key Vault
Remove-AzureRmKeyVault -VaultName $keyVault.VaultName -ResourceGroupName $rgName -Confirm:$false

# Delete Image
Remove-AzureRmImage -ImageName $imageName -ResourceGroupName $rgName -Confirm:$false
