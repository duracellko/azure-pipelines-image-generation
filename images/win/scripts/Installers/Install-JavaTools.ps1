################################################################################
##  File:  Install-JavaTools.ps1
##  Team:  CI-X
##  Desc:  Install various JDKs and java tools
################################################################################

## Downloading azul jdks
$azulJDK8Uri = 'https://repos.azul.com/azure-only/zulu/packages/zulu-8/8u181/zulu-8-azure-jdk_8.31.0.2-8.0.181-win_x64.zip'

cd $env:TEMP

Invoke-WebRequest -UseBasicParsing -Uri $azulJDK8Uri -OutFile azulJDK8.zip

# Expand the zips
Expand-Archive -Path azulJDK8.zip -DestinationPath "C:\Program Files\Java\" -Force

# Deleting zip folders
Remove-Item -Recurse -Force azulJDK8.zip

Import-Module -Name ImageHelpers -Force

$currentPath = Get-MachinePath

$pathSegments = $currentPath.Split(';')
$newPathSegments = @()

foreach ($pathSegment in $pathSegments)
{
    if($pathSegment -notlike '*java*')
    {
        $newPathSegments += $pathSegment
    }
}

$java8Installs = Get-ChildItem -Path 'C:\Program Files\Java' -Filter '*azure-jdk*8*' | Sort-Object -Property Name -Descending | Select-Object -First 1
$latestJava8Install = $java8Installs.FullName;

$newPath = [string]::Join(';', $newPathSegments)
$newPath = $latestJava8Install + '\bin;' + $newPath

Set-MachinePath -NewPath $newPath

setx JAVA_HOME $latestJava8Install /M
setx JAVA_HOME_8_X64 $latestJava8Install /M
