<#

.SYNOPSIS
    This script test whether non admin users are able to use administrative
    tools.

.DESCRIPTION
    It checks whether the users in the group BUILTIN\Users have access to a
    list of administrative tools and gives you a summary of which tools they
    can or cannot use.

.EXAMPLE
    Test-AdministrativeToolsPermissions

.NOTES
    Name: Test-AdministrativeToolsPermissions
    Author: Cristhian Amaya <cam at camaya.co>
    Version: 1.0.0

.LINK
    https://github.com/camaya/winfortress

#>

[CmdletBinding()]
Param()

. ".\Winfortress.AdministrativeTools.ps1"

$toolsWithAccess = New-Object System.Collections.Generic.List[System.String]
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
        $toolsWithAccess.Add($tool)
    }
}

if ($toolsWithAccess.Count -gt 0)
{
    Write-Host "`nUsers in the $($USERS_GROUP) group have access to:`n" -ForegroundColor Cyan
    foreach($toolWithAccess in $toolsWithAccess)
    {
        Write-Output "`t$($toolWithAccess)"
    }
}

Write-Host "`nSummary`n" -ForegroundColor Cyan

if ($toolsWithAccess.Count -eq 0)
{
    Write-Host "Users in the $($USERS_GROUP) group do not have access to any of the administrative tools." -ForegroundColor Green
}
elseif ($toolsWithAccess.Count -eq $tools.Count)
{
    Write-Host "Users in the $($USERS_GROUP) group have access to *all* of the administrative tools." -ForegroundColor Red
}
else
{
    Write-Host "Users in the $($USERS_GROUP) group have access to $($toolsWithAccess.Count) of $($tools.Count) administrative tools." -ForegroundColor Yellow
}
