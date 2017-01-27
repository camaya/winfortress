# Winfortress

Winfortress is a collection of scripts aiming to enhance the security of a Windows 10 machine. I say specifically Windows 10 because that's the only environment where the scripts have been tested.
At the moment, there are scripts to configure Windows security related settings and the permissions of some administrative tools.

# Winfortress Scripts

You can get information and examples for each script by executing Get-Help [Script].
Here's the list of the scripts and a short description for each one.

### Test-WindowsSecurityConfiguration

This script tests whether your Windows 10 machine is configured correctly from a security point of view.

### Backup-WindowsSecurityConfiguration

This script creates a backup of the registry keys associated with some security settings.

### Protect-WindowsSecurityConfiguration

This scripts protects your windows 10 machine by setting some options that enhance its security.

### Test-AdministrativeToolsPermissions

This script test whether non admin users are able to use administrative tools.

### Protect-AdministrativeToolsPermissions

This script protects your administrative tools by disallowing non admin users to use them.

### Unprotect-AdministrativeToolsPermisions

This script *unprotects* your administrative tools by allowing non admin users to use them.

# License

Winfortress is released under [MIT license](http://www.opensource.org/licenses/MIT).
