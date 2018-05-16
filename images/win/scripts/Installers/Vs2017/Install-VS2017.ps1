################################################################################
##  File:  Install-VS2017.ps1
##  Team:  CI-Build
##  Desc:  Install Visual Studio 2017
################################################################################

Function InstallVS
{
  Param
  (
    [String]$WorkLoads,
    [String]$Sku,
    [String] $VSBootstrapperURL
  )

  $exitCode = -1

  try
  {
    Write-Host "Downloading Bootstrapper ..."
    Invoke-WebRequest -Uri $VSBootstrapperURL -OutFile "${env:Temp}\vs_$Sku.exe"

    $FilePath = "${env:Temp}\vs_$Sku.exe"
    $Arguments = ('/c', $FilePath, $WorkLoads, '--quiet', '--norestart', '--wait', '--nocache' )

    Write-Host "Starting Install ..."
    $process = Start-Process -FilePath cmd.exe -ArgumentList $Arguments -Wait -PassThru
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0 -or $exitCode -eq 3010)
    {
      Write-Host -Object 'Installation successful'
      return $exitCode
    }
    else
    {
      Write-Host -Object "Non zero exit code returned by the installation process : $exitCode."

      # this wont work because of log size limitation in extension manager
      # Get-Content $customLogFilePath | Write-Host

      exit $exitCode
    }
  }
  catch
  {
    Write-Host -Object "Failed to install Visual Studio. Check the logs for details in $customLogFilePath"
    Write-Host -Object $_.Exception.Message
    exit -1
  }
}

$WorkLoads = '--add Microsoft.VisualStudio.Workload.CoreEditor ' + `
                '--add Microsoft.VisualStudio.Workload.ManagedDesktop ' + `
                '--add Microsoft.Net.ComponentGroup.TargetingPacks.Common ' + `
                '--add Microsoft.VisualStudio.Component.Debugger.JustInTime ' + `
                '--add Microsoft.Net.Component.4.7.SDK ' + `
                '--add Microsoft.Net.Component.4.7.TargetingPack ' + `
                '--add Microsoft.Net.ComponentGroup.4.7.DeveloperTools ' + `
                '--add Microsoft.Net.Component.4.7.1.SDK ' + `
                '--add Microsoft.Net.Component.4.7.1.TargetingPack ' + `
                '--add Microsoft.Net.ComponentGroup.4.7.1.DeveloperTools ' + `
                '--add Microsoft.VisualStudio.Workload.NetWeb ' + `
                '--add Microsoft.VisualStudio.Component.Web ' + `
                '--add Microsoft.VisualStudio.Workload.Universal ' + `
                '--add Microsoft.VisualStudio.Component.Windows10SDK.15063.UWP ' + `
                '--add Microsoft.VisualStudio.Component.Windows10SDK.16299.UWP ' + `
                '--add Microsoft.VisualStudio.Workload.NetCrossPlat ' + `
                '--add Microsoft.VisualStudio.Component.Azure.Storage.AzCopy ' + `
                '--add Component.Android.SDK25 ' + `
                '--add Component.JavaJDK ' + `
                '--add Component.Xamarin ' + `
                '--add Component.Xamarin.SdkManager '

$Sku = 'Enterprise'
$VSBootstrapperURL = 'https://aka.ms/vs/15/release/vs_enterprise.exe'

$ErrorActionPreference = 'Stop'

# Install VS
$exitCode = InstallVS -WorkLoads $WorkLoads -Sku $Sku -VSBootstrapperURL $VSBootstrapperURL

# Find the version of VS installed for this instance
# Only supports a single instance
$vsProgramData = Get-Item -Path "C:\ProgramData\Microsoft\VisualStudio\Packages\_Instances"
$instanceFolders = Get-ChildItem -Path $vsProgramData.FullName

if($instanceFolders -is [array])
{
    Write-Host "More than one instance installed"
    exit 1
}

$catalogContent = Get-Content -Path ($instanceFolders.FullName + '\catalog.json')
$catalog = $catalogContent | ConvertFrom-Json
$version = $catalog.info.id
Write-Host "Visual Studio version" $version "installed"

# Updating content of MachineState.json file to disable autoupdate of VSIX extensions
$newContent = '{"Extensions":[{"Key":"1e906ff5-9da8-4091-a299-5c253c55fdc9","Value":{"ShouldAutoUpdate":false}},{"Key":"Microsoft.VisualStudio.Web.AzureFunctions","Value":{"ShouldAutoUpdate":false}}],"ShouldAutoUpdate":false,"ShouldCheckForUpdates":false}'
Set-Content -Path "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\Extensions\MachineState.json" -Value $newContent


# Adding description of the software to Markdown

$SoftwareName = "Visual Studio 2017 Enterprise"

$Description = @"
_Version:_ $version<br/>
_Location:_ C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise

The following workloads including required and recommended components are installed with Visual Studio 2017:

* Universal Windows Platform development
* .NET desktop development
* ASP.NET and web development
* Mobile development with .NET

In addition the following optional components are installed:

"@

Add-SoftwareDetailsToMarkdown -SoftwareName $SoftwareName -DescriptionMarkdown $Description

# Adding explicitly added Workloads details to markdown by parsing $Workloads
Add-ContentToMarkdown -Content $($WorkLoads.Split('--') | % { if( ($_.Split(" "))[0] -like "add") { "* " +($_.Split(" "))[1] }  } )



# Setup Android SDK path for Xamarin
$androidSdkRegistryPath = 'HKLM:\SOFTWARE\WOW6432Node\Android SDK Tools'
if (!(Test-Path $androidSdkRegistryPath)) {
    New-Item -Path $androidSdkRegistryPath -ItemType Directory
    New-ItemProperty -Path $androidSdkRegistryPath -Name 'Path' -Value 'C:\Program Files (x86)\Android\android-sdk' -PropertyType String
}

exit $exitCode