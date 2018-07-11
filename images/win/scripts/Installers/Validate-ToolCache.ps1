# Python
$pythonVersions = @(
    ('2.7.14', 'x86'),
    ('3.4.4', 'x86'),
    ('3.5.4', 'x86'),
    ('3.6.4', 'x86'),
    ('3.7.0', 'x86')
    ('2.7.14', 'x64'),
    ('3.4.4', 'x64'),
    ('3.5.4', 'x64'),
    ('3.6.4', 'x64'),
    ('3.7.0', 'x64')
)

foreach ($version in $pythonVersions)
{
    $v = $version[0]
    $arch = $version[1]
    $path = "$env:AGENT_TOOLSDIRECTORY\Python\$v\$arch"

    if (Test-Path "$path\python.exe")
    {
        Write-Host "Python $v ($arch) is successfully installed:"
        Write-Host (& "$path\python.exe" --version)
    }
    else
    {
        Write-Host "Python $v ($arch) is not installed"
        exit 1
    }

    if (Test-Path "$path\Scripts\pip.exe")
    {
        Write-Host "Pip for Python $v ($arch) is successfully installed:"
        Write-Host (& "$path\Scripts\pip.exe" --version)
    }
    else
    {
        Write-Host "Pip for Python $v ($arch) is not installed"
        exit 1
    }
}