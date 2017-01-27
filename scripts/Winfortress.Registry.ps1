<#

.SYNOPSIS
    This script contains common variables and functions to work with the 
    Windows registry.

.EXAMPLE
    . Winfortress.Registry.ps1

.NOTES
    Name: Winfortress.Registry.ps1
    Author: Cristhian Amaya <cam at camaya.co>
    Version: 1.0.0

.LINK
    https://github.com/camaya/winfortress

#>

function Get-RegistryValueData($KeyPath, $ValueName)
{
    $keyExists = Test-Path $KeyPath
    if (-not ($keyExists))
    {
        Write-Verbose "The key $($KeyPath) does not exists"
        return $null
    }

    $key = Get-Item -LiteralPath $KeyPath
    $value = $key.GetValue($ValueName)

    if ($value -eq $null)
    {
        Write-Verbose "The value $($ValueName) does not exists on the key $($KeyPath)"
        return $null
    }

    return $value
}

$windowsSecurityRecommendedSettings = [ordered]@{
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\FilterAdministratorToken" = @{
        "Name" = "User Account Control: Admin Approval Mode for the Built-in Administrator account";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviorAdmin" = @{
        "Name" = "User Account Control: Behavior of the elevation prompt for administrators in Admin Approval Mode";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Elevate without prompting"; "IsRecommended" = $false};
            "1" = @{"Value" = "Prompt for credentials on the secure desktop"; "IsRecommended" = $true};
            "2" = @{"Value" = "Prompt for consent on the secure desktop"; "IsRecommended" = $false};
            "3" = @{"Value" = "Prompt for credentials"; "IsRecommended" = $false};
            "4" = @{"Value" = "Prompt for consent"; "IsRecommended" = $false};
            "5" = @{"Value" = "Prompt for consent for non-Windows binaries"; "IsRecommended" = $false};
        }
    };
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviorUser" = @{
        "Name" = "User Account Control: Behavior of the elevation prompt for standard users";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Automatically deny elevation requests"; "IsRecommended" = $false}
            "1" = @{"Value" = "Prompt for credentials on the secure desktop"; "IsRecommended" = $true}
            "3" = @{"Value" = "Prompt for credentials"; "IsRecommended" = $false}
        }
    };
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableInstallerDetection" = @{
        "Name" = "User Account Control: Detect application installations and prompt for elevation";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\CredUI\EnumerateAdministrators" = @{
        "Name" = "Enumerate administrator accounts on elevation";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\restrictanonymoussam" = @{
        "Name" = "Network access: Do not allow anonymous enumeration of SAM accounts";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\RestrictAnonymous" = @{
        "Name" = "Network access: Do not allow anonymous enumeration of SAM accounts and shares";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters\NullSessionShares" = @{
        "Name" = "Network access: Restrict anonymous access to Named Pipes and Shares";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\DisableDomainCreds" = @{
        "Name" = "Network access: Do not allow storage of passwords and credentials for network authentication";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0\allownullsessionfallback" = @{
        "Name" = "Network security: Allow LocalSystem NULL session fallback";
        "RecommendedValue" = "0";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $true};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $false}
        }
    };
    "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\LmCompatibilityLevel" = @{
        "Name" = "Network security: LAN Manager authentication level";
        "RecommendedValue" = "5";
        "PossibleValues" = @{
            "0" = @{"Value" = "Send LM & NTLM responses"; "IsRecommended" = $false};
            "1" = @{"Value" = "Send LM & NTLM – use NTLMv2 session security if negotiated"; "IsRecommended" = $false};
            "2" = @{"Value" = "Send NTLM response only"; "IsRecommended" = $false};
            "3" = @{"Value" = "Send NTLMv2 response only"; "IsRecommended" = $false};
            "4" = @{"Value" = "Send NTLMv2 response only. Refuse LM"; "IsRecommended" = $false};
            "5" = @{"Value" = "Send NTLMv2 response only. Refuse LM & NTLM"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers\AddPrinterDrivers" = @{
        "Name" = "Devices: Prevent users from installing printer drivers when connecting to shared printers";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\DontDisplayLockedUserId" = @{
        "Name" = "Interactive logon: Display user information when the session is locked";
        "RecommendedValue" = "3";
        "PossibleValues" = @{
            "1" = @{"Value" = "User display name, domain and user names"; "IsRecommended" = $false; "IsCritical" = $false};
            "2" = @{"Value" = "User display name only"; "IsRecommended" = $false};
            "3" = @{"Value" = "Do not display user information"; "IsRecommended" = $true;}
        }
    };
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\DontDisplayLastUsername" = @{
        "Name" = "Interactive logon: Do not display last user name";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer\NoAutoplayfornonVolume" = @{
        "Name" = "Disallow Autoplay for non-volume devices";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer\NoDriveTypeAutoRun" = @{
        "Name" = "Turn off AutoPlay";
        "RecommendedValue" = "FF";
        "PossibleValues" = @{
            "FF" = @{"Value" = "Disable AutoRun on all drives"; "IsRecommended" = $true;};
            "20" = @{"Value" = "Disable AutoRun on CD-ROM drives"; "IsRecommended" = $false};
            "4" = @{"Value" = "Disable AutoRun on removable drives"; "IsRecommended" = $false};
            "8" = @{"Value" = "Disable AutoRun on fixed drives"; "IsRecommended" = $false};
            "10" = @{"Value" = "Disable AutoRun on network drives"; "IsRecommended" = $false};
            "40" = @{"Value" = "Disable AutoRun on RAM disks"; "IsRecommended" = $false};
            "1" = @{"Value" = "Disable AutoRun on unknown drives"; "IsRecommended" = $false}
        }
    };
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoAutoRun" = @{
        "Name" = "Set the default behavior for AutoRun";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "1" = @{"Value" = "Enabled - Do not execute any autorun commands"; "IsRecommended" = $true};
            "2" = @{"Value" = "Enabled - Automatically execute autorun commands"; "IsRecommended" = $false}
        }
    };
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\AllowBasic" = @{
        "Name" = "Remote Desktop - Allow Basic authentication";
        "RecommendedValue" = "0";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $true;};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $false}
        }
    };
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\AllowUnencryptedTraffic" = @{
        "Name" = "Remote Desktop - Allow unencrypted traffic";
        "RecommendedValue" = "0";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $true;};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $false}
        }
    };
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\Power\PromptPasswordOnResume" = @{
        "Name" = "Prompt for password on resume from hibernate/suspend";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt" = @{
        "Name" = "Hide extensions for known file types";
        "RecommendedValue" = "0";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $true};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $false}
        }
    };
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Hidden" = @{
        "Name" = "Hidden files and folders";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "1" = @{"Value" = "Show hidden files, folders, and drives"; "IsRecommended" = $true};
            "2" = @{"Value" = "Don't show hidden files, folders, or drives"; "IsRecommended" = $false}
        }
    };
}

$windowsSecurityOptionalSettings = [ordered]@{
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization\NoLockScreenCamera" = @{
        "Name" = "Prevent enabling lock screen camera";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    };
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\AllowTelemetry" = @{
        "Name" = "Allow Telemetry";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "1" = @{"Value" = "Basic"; "IsRecommended" = $true};
            "2" = @{"Value" = "Enhanced"; "IsRecommended" = $false};
            "3" = @{"Value" = "Full"; "IsRecommended" = $false};
        }
    };
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive\DisableFileSyncNGSC" = @{
        "Name" = "Prevent the usage of OneDrive for file storage";
        "RecommendedValue" = "1";
        "PossibleValues" = @{
            "0" = @{"Value" = "Disabled"; "IsRecommended" = $false};
            "1" = @{"Value" = "Enabled"; "IsRecommended" = $true}
        }
    }
}