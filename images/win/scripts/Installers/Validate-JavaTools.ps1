################################################################################
##  File:  Validate-JavaTools.ps1
##  Team:  CI-X
##  Desc:  Validate various JDKs and java tools
################################################################################

if(Get-Command -Name 'java')
{
    Write-Host "Java $(java -version) on path"
    exit 0
}
else
{
    Write-Host "Java is not on path."
    exit 1
}