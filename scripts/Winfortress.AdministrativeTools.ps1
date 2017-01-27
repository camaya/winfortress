<#

.SYNOPSIS
    This script contains common variables and functions to work with the 
    administrative tools.

.EXAMPLE
    . Winfortress.AdministrativeTools.ps1

.NOTES
    Name: Winfortress.AdministrativeTools.ps1
    Author: Cristhian Amaya <cam at camaya.co>
    Version: 1.0.0

.LINK
    https://github.com/camaya/winfortress

#>

function Test-UserAccess($Tool)
{
    $acl = Get-Acl $tool
    $usersAccess = $acl.Access | where {$_.IdentityReference -eq $USERS_GROUP}
    $usersHaveAccess = $usersAccess -ne $null
    return $usersHaveAccess
}

$USERS_GROUP = "BUILTIN\Users"
$tools = @(
    "C:\Windows\System32\arp.exe",
    "C:\Windows\System32\at.exe",
    "C:\Windows\System32\attrib.exe",
    "C:\Windows\System32\cacls.exe",
    "C:\Windows\System32\eventcreate.exe",
    "C:\Windows\System32\ftp.exe",
    "C:\Windows\System32\icacls.exe",
    "C:\Windows\System32\nbtstat.exe",
    "C:\Windows\System32\net.exe",
    "C:\Windows\System32\net1.exe",
    "C:\Windows\System32\netsh.exe",
    "C:\Windows\System32\netstat.exe",
    "C:\Windows\System32\nslookup.exe",
    "C:\Windows\System32\reg.exe",
    "C:\Windows\System32\regedt32.exe",
    "C:\Windows\System32\regini.exe",
    "C:\Windows\System32\regsvr32.exe",
    "C:\Windows\System32\route.exe",
    "C:\Windows\System32\sc.exe",
    "C:\Windows\System32\schtasks.exe",
    "C:\Windows\System32\secedit.exe",
    "C:\Windows\System32\subst.exe",
    "C:\Windows\System32\systeminfo.exe",
    "C:\Windows\regedit.exe"
)