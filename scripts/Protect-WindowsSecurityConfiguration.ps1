#Requires -Version 3.0
#Requires -RunAsAdministrator

<#

.SYNOPSIS
    This scripts protects your windows 10 machine by setting some options
    that enhance its security.

.DESCRIPTION
    It checks multiple registry keys that control different security related
    settings that you can find on gpedit.msc and secpol.msc and it set them 
    to a recommended value.

.EXAMPLE
    .\Protect-WindowsSecurityConfiguration
    Creates a backup of your current settings and then apply the recommended
    settings.

.EXAMPLE
    .\Protect-WindowsSecurityConfiguration -NoBackup -IncludeOptionals
    Apply the recommended and optional settings without creating a backup first.

.NOTES
    Name: Protect-WindowsSecurityConfiguration.ps1
    Author: Cristhian Amaya <cam at camaya.co>
    Version: 1.0.0

.LINK
    https://github.com/camaya/winfortress

#>

[CmdletBinding()]
Param(
    [Parameter()]
    [switch]$NoBackup,

    [Parameter()]
    [switch]$IncludeOptionals
)

. ".\Winfortress.Registry.ps1"

function Set-SettingsValueData($SettingsConfig)
{
    $settingsConfigured = 0
    foreach ($key in $SettingsConfig.Keys)
    {
        $keyPath = $key.substring(0, $key.LastIndexOf("\"))
        $valueName = $key.substring($key.LastIndexOf("\") + 1)
        $settingInfo = $SettingsConfig.Item($key)

        if (-not (Test-Path $keyPath))
        {
            Write-Verbose "Creating the $($keyPath) key in the registry."
            New-Item -Path $keyPath -Force | Out-Null
        }

        $settingValueData = Get-RegistryValueData -KeyPath $keyPath -ValueName $valueName
        if ($settingValueData -eq $settingInfo["RecommendedValue"])
        {
            Write-Verbose "$($settingInfo["Name"]) is already configured as recommended."
            continue
        }

        Write-Verbose "`nCurrent Value: $($settingValueData)`n"
        Write-Verbose "Setting the recommended value ($($settingInfo["RecommendedValue"])) to the registry value $($key)."
        Set-ItemProperty -Path $keyPath -Name  $valueName -Value $settingInfo["RecommendedValue"] | Out-Null
        
        $settingsConfigured += 1
    }
    return $settingsConfigured
}

if ($NoBackup -eq $false)
{
    .\Backup-WindowsSecurityConfiguration.ps1
}

$changedSettingsCount = Set-SettingsValueData -SettingsConfig $windowsSecurityRecommendedSettings

if ($IncludeOptionals)
{
    $changedSettingsCount += Set-SettingsValueData -SettingsConfig $windowsSecurityOptionalSettings
}

if ($changedSettingsCount -eq 0)
{
    Write-Host "Your system is already protected!" -ForegroundColor Green
    Write-Host "No changes have been made." -ForegroundColor Cyan
}
else
{
    Write-Host "Your system has been protected!" -ForegroundColor Green
    Write-Host "$($changedSettingsCount) options have been changed successfully." -ForegroundColor Cyan
}
