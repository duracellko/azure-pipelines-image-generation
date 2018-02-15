param
(
    [string] $rgName,
    [string] $location,
    [string] $VMName,
    [PSCredential] $cred,
    [string] $VSTSAccount,
    [string] $PAT,
    [string] $VSTSAgentUrl,
    [string] $AgentPool = 'default'
)

# Get VM IP address
$vm = Get-AzureRmVM -ResourceGroupName $rgName -Name $VMName
$nicId = $vm.NetworkProfile.NetworkInterfaces.Id
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $rgName | Where-Object { $_.Id -eq $nicId }
$publicIpId = $nic.IpConfigurations.PublicIpAddress.Id
$publicIp = Get-AzureRmPublicIpAddress -ResourceGroupName $rgName | Where-Object { $_.Id -eq $publicIpId }
$vmAddress = $publicIp.IpAddress
Write-Output "Connecting to VM $($publicIp.IpAddress)"

$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$session = New-PSSession -ComputerName $vmAddress -UseSSL -Credential $cred -SessionOption $sessionOption
$remoteArgs = @($VSTSAgentUrl, $VSTSAccount, $PAT, $VMName, $AgentPool)
Invoke-Command -Session $session -ArgumentList $remoteArgs -ScriptBlock {
    param
    (
        [string] $VSTSAgentUrl,
        [string] $VSTSAccount,
        [string] $PAT,
        [string] $VMName,
        [string] $AgentPool
    )

    function GetRandomPassword {
        $sourceChars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$^&(){}[],.'
        $max = $sourceChars.Length
        $result = ''
        for ($i = 0; $i -lt 20; $i += 1) {
            $index = Get-Random -Minimum 0 -Maximum $max
            $c = $sourceChars[$index]
            $result += $c
        }

        return $result
    }

    # Create and format partition G:
    $disk = Get-Disk | Where-Object { $_.PartitionStyle -eq 'RAW' }
    Initialize-Disk -InputObject $disk -PartitionStyle GPT
    $partition = New-Partition -InputObject $disk -UseMaximumSize -DriveLetter 'G'
    Format-Volume -Partition $partition -FileSystem NTFS -NewFileSystemLabel 'BUILD' -Confirm:$true
    Write-Output 'Formatted volume G:'

    # Create user svcBuild
    $serviceUserName = 'svcBuild'
    $servicePassword = GetRandomPassword
    $serviceSecurePassword = ConvertTo-SecureString $servicePassword -AsPlainText -Force
    $args = @{
        Name = $serviceUserName
        Password = $serviceSecurePassword
        FullName = 'BuildService'
        AccountNeverExpires = $true
        PasswordNeverExpires = $true
    }
    $serviceUser = New-LocalUser @args
    $administratorsGroup = Get-LocalGroup -Name 'Administrators'
    Add-LocalGroupMember -Group $administratorsGroup -Member $serviceUser
    Write-Output 'Created user svcBuild'

    # Disable installer user, that installed Visual Studio 2017
    Disable-LocalUser -Name 'installer'
    Write-Host 'Disabled user installer'

    Set-Location 'G:\'

    # Download VSTS Agent
    $vstsAgentZipPath = "vsts-agent.zip"
    Invoke-WebRequest -Uri $VSTSAgentUrl -UseBasicParsing -OutFile $vstsAgentZipPath
    Write-Output 'Downloaded vsts-agent.zip'

    # Unzip VSTS Agent
    $buildFolder = New-Item -Path 'Build' -ItemType Directory
    Expand-Archive -Path $vstsAgentZipPath -DestinationPath $buildFolder.FullName
    Set-Location $buildFolder.FullName
    Write-Output 'Extracted vsts-agent.zip'

    $serviceUserQualifiedName = "$VMName\$serviceUserName"
    & .\config.cmd --unattended  --url "`"https://$VSTSAccount.visualstudio.com`"" --auth pat --token "`"$PAT`"" --pool "`"$AgentPool`"" --agent "`"$VMName`"" --runAsService --windowsLogonAccount "`"$serviceUserQualifiedName`"" --windowsLogonPassword "`"$servicePassword`""
    Write-Output 'VSTS Build Agent configured.'
}

Remove-PSSession -Session $session