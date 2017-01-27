#Requires -Version 3.0
#Requires -RunAsAdministrator

<#

.SYNOPSIS
    This script protects your administrative tools by disallowing non admin
    users to use them.

.DESCRIPTION
    It checks whether the users in the group BUILTIN\Users have access to a
    list of administrative tools and if so, it modifies each tool's NTFS permissions
    to remove the BUILTIN\Users group.

.EXAMPLE
    Protect-AdministrativeToolsPermissions

.NOTES
    Name: Protect-AdministrativeToolsPermissions
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
    if ($usersHaveAccess)
    {
        takeown /f $($tool)
        icacls $($tool) /remove:g $($USERS_GROUP)
    }
}
