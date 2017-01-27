#Requires -Version 3.0
#Requires -RunAsAdministrator

<#

.SYNOPSIS
    This script *unprotects* your administrative tools by allowing non admin
    users to use them.

.DESCRIPTION
    It checks whether the users in the group BUILTIN\Users have access to a
    list of administrative tools and if they do not, it modifies each tool's
    NTFS permissions to add the BUILTIN\Users group.

    This basically does the opposite of Protect-AdministrativeTools.

.EXAMPLE
    Unprotect-AdministrativeToolsPermissions

.NOTES
    Name: Unprotect-AdministrativeToolsPermissions
    Author: Cristhian Amaya <cam at camaya.co>
    Version: 1.0.0

.LINK
    https://github.com/camaya/winfortress

#>

[CmdletBinding()]
Param()

. ".\Winfortress.AdministrativeTools.ps1"

foreach ($tool in $tools)
{
    if (-not (Test-Path $tool))
    {
        Write-Host "$($tool) does not exist in this machine." -ForegroundColor Yellow
        continue
    }

    $usersHaveAccess = Test-UserAccess -Tool $tool
    if (-not $usersHaveAccess)
    {
        takeown /f $($tool)
        icacls "$($tool)" "/grant:r" "$($USERS_GROUP):(RX)"
    }
}
