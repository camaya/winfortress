#Requires -Version 3.0
#Requires -RunAsAdministrator

<#

.SYNOPSIS
    This script creates a backup of the registry keys associated with some
    security settings.
    All the registry keys that are backed up in the Winfortress.Registry.ps1 file.

.DESCRIPTION
    It reads the registry keys associated with each security setting and saves
    the current data values in a .reg file.

.EXAMPLE
    .\Backup-WindowsSecurityConfiguration.ps1
    Creates a backup in the current directory including the optional settings.

.EXAMPLE
    .\Backup-WindowsSecurityConfiguration.ps1 -Path C:\Foo -NoOptionals
    Creates a backup in the C:\Foo directory without including the optional
    settings.

.NOTES
    Name: Backup-WindowsSecurityConfiguration.ps1
    Author: Cristhian Amaya <cam at camaya.co>
    Version: 1.0.0

.LINK
    https://github.com/camaya/winfortress

#>

[CmdletBinding()]
Param(
    [Parameter()]
    [string]$Path = ".",

    [Parameter()]
    [switch]$NoOptionals
)

. ".\Winfortress.Registry.ps1"

function Add-BackupLine($Text, $BlankLinesCount)
{
    $content += $Text
    if ($BlankLinesCount -gt 0)
    {
        $content += "`r`n" * $BlankLinesCount
    }
    return $content
}

# .reg file format: https://support.microsoft.com/en-us/help/310516/how-to-add,-modify,-or-delete-registry-subkeys-and-values-by-using-a-.reg-file
function Add-BackupSettings($Settings)
{
    $backupSettings = ""
    foreach($key in $Settings.Keys)
    {
        $keyPath = $key.substring(0, $key.LastIndexOf("\"))
        $keyPathExpanded = $keyPath.Replace("HKLM:", "HKEY_LOCAL_MACHINE")
        $valueName = $key.substring($key.LastIndexOf("\") + 1)

        $settingValueData = Get-RegistryValueData -KeyPath $keyPath -ValueName $valueName

        if ($settingValueData -eq $null)
        {
            $backupSettings += Add-BackupLine -Text "[$($keyPathExpanded)]" -BlankLinesCount 1
            $backupSettings += Add-BackupLine -Text `"$valueName`"=- -BlankLinesCount 2
        }
        else
        {
            $backupSettings += Add-BackupLine -Text "[$($keyPathExpanded)]" -BlankLinesCount 1
            $backupSettings += Add-BackupLine -Text `"$valueName`"=dword:$settingValueData -BlankLinesCount 2
        }
    }
    return $backupSettings
}

$backup = Add-BackupLine -Text "Windows Registry Editor Version 5.00" -BlankLinesCount 2
$backup += Add-BackupSettings -Settings $windowsSecurityRecommendedSettings

if ($NoOptionals -eq $false)
{
    $backup += Add-BackupSettings -Settings $windowsSecurityOptionalSettings
}

if (-not (Test-Path $Path))
{
    New-Item -ItemType Directory -Path $Path | Out-Null
}

$backupPath = "$($Path)\WindowsSecurityConfiguration_$(Get-Date -format yyyyMMddhhmmss).reg"
$backup | Out-File "$($backupPath)"

Write-Host "Backup generated successfully at $($backupPath)" -ForegroundColor Green
