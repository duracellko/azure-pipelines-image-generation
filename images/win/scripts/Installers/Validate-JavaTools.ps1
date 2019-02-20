################################################################################
##  File:  Validate-JavaTools.ps1
##  Team:  CI-X
##  Desc:  Validate various JDKs and java tools
################################################################################

if(Get-Command -Name 'java')
{
    Write-Host "Java $(java -version) on path"
}
else
{
    Write-Host "Java is not on path."
    exit 1
}


if( $( $(& $env:comspec "/s /c java -version 2>&1") | Out-String) -match  '^(?<vendor>.+) version "(?<version>.+)".*' )
{
   $javaVersion = $Matches.version
}

# Adding description of the software to Markdown
$SoftwareName = "Java Development Kit"

$Description = @"
#### $javaVersion

_Environment:_
* JAVA_HOME: location of JDK
* PATH: contains bin folder of JDK
"@

Add-SoftwareDetailsToMarkdown -SoftwareName $SoftwareName -DescriptionMarkdown $Description
