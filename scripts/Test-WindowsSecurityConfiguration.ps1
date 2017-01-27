#Requires -Version 3.0
#Requires -RunAsAdministrator

<#

.SYNOPSIS
    This script tests whether your Windows 10 machine is configured correctly
    from a security point of view.
    All the registry keys that are checked in the Winfortress.Registry.ps1 file.

.DESCRIPTION
    It checks multiple registry keys that control different security related
    settings that you can find on gpedit.msc and secpol.msc and it gives you a
    summary comparing your current settings with the recommended ones.

.EXAMPLE
    .\Test-WindowsSecurityConfiguration.ps1

.NOTES
    Name: Test-WindowsSecurityConfiguration.ps1
    Author: Cristhian Amaya <cam at camaya.co>
    Version: 1.0.0

.LINK
    https://github.com/camaya/winfortress

#>

[CmdletBinding()]
Param()

. ".\Winfortress.Registry.ps1"

$OK_KEY = "Ok"
$KO_KEY = "Ko"
$NOT_CONFIGURED_KEY = "NotConfigured"

function Get-SettingsStatus($SettingsConfig)
{
    $status = @{
        $OK_KEY = [ordered]@{};
        $KO_KEY = [ordered]@{};
        $NOT_CONFIGURED_KEY = [ordered]@{}
    }

    foreach ($key in $SettingsConfig.Keys)
    {
        $keyPath = $key.substring(0, $key.LastIndexOf("\"))
        $valueName = $key.substring($key.LastIndexOf("\") + 1)
        $settingInfo = $SettingsConfig.Item($key)
        $settingValue = Get-RegistryValueData -KeyPath $keyPath -ValueName $valueName

        if ($settingValue -eq $null)
        {
            $status[$NOT_CONFIGURED_KEY].Add($settingInfo.Name, "Not Configured")
        }
        elseif ($settingInfo.PossibleValues["$($settingValue)"].IsRecommended)
        {
            $status[$OK_KEY].Add($settingInfo.Name, $settingInfo.PossibleValues["$($settingValue)"].Value)
        }
        else
        {
            $status[$KO_KEY].Add($settingInfo.Name, $settingInfo.PossibleValues["$($settingValue)"].Value)
        }
    }

    return $status
}

function Write-SettingStatus($Prefix, $Name, $Value, $Color)
{
    if ($Prefix -ne $null)
    {
        Write-Host "$($Prefix) " -NoNewline
    }

    Write-Host "$($Name): " -NoNewline
    Write-Host "$($Value)" -ForegroundColor $Color
}

function Write-SettingsStatus($SettingsStatus, $MessagePrefix)
{
    foreach($key in $SettingsStatus[$KO_KEY].Keys)
    {
        Write-SettingStatus -Prefix $MessagePrefix -Name $key -Value $SettingsStatus[$KO_KEY][$key] -Color Red
    }

    foreach($key in $SettingsStatus[$NOT_CONFIGURED_KEY].Keys)
    {
        Write-SettingStatus -Prefix $MessagePrefix -Name $key -Value $SettingsStatus[$NOT_CONFIGURED_KEY][$key] -Color Yellow
    }

    foreach($key in $SettingsStatus[$OK_KEY].Keys)
    {
        Write-SettingStatus -Prefix $MessagePrefix -Name $key -Value $SettingsStatus[$OK_KEY][$key] -Color Green
    }
}

function Write-SettingsSummary($Title, $Settings, $SettingsStatus)
{
    Write-Output "`n$($Title)"

    Write-Host "`tYou have $($SettingsStatus[$KO_KEY].Count)/$($Settings.Count) " -NoNewLine
    Write-Host "configured incorrectly" -ForegroundColor Red

    Write-Host "`tYou have $($SettingsStatus[$NOT_CONFIGURED_KEY].Count)/$($Settings.Count) " -NoNewline
    Write-Host "not configured" -ForegroundColor Yellow

    Write-Host "`tYou have $($SettingsStatus[$OK_KEY].Count)/$($Settings.Count) " -NoNewline
    Write-Host "configured correctly" -ForegroundColor Green
}

$recommendedSettingsStatus = Get-SettingsStatus -SettingsConfig $windowsSecurityRecommendedSettings
$optionalSettingsStatus = Get-SettingsStatus -SettingsConfig $windowsSecurityOptionalSettings

Write-Output "`n"
Write-SettingsStatus -SettingsStatus $recommendedSettingsStatus
Write-SettingsStatus -SettingsStatus $optionalSettingsStatus -MessagePrefix "[Optional]"

Write-SettingsSummary -Title "Recommended Settings Summary" -Settings $windowsSecurityRecommendedSettings -SettingsStatus $recommendedSettingsStatus
Write-SettingsSummary -Title "Optional Settings Summary" -Settings $windowsSecurityOptionalSettings -SettingsStatus $optionalSettingsStatus
Write-Output "`n"
