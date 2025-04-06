using module Message
using module ElevateScript

#
# ░█░█░▀█▀░█▀█░█▀▄░█▀█░█░█░█▀▀░░░█▀▀░█▀▀░█▀█░▀█▀░█░█░█▀▄░█▀▀░█▀▀
# ░█▄█░░█░░█░█░█░█░█░█░█▄█░▀▀█░░░█▀▀░█▀▀░█▀█░░█░░█░█░█▀▄░█▀▀░▀▀█
# ░▀░▀░▀▀▀░▀░▀░▀▀░░▀▀▀░▀░▀░▀▀▀░░░▀░░░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀░▀▀▀░▀▀▀
#

$osInfo = Get-CimInstance Win32_OperatingSystem
$osVersion = [Version]$osInfo.Version
$osBuild = $osInfo.BuildNumber

if ($osVersion.Major -lt 10 -or ($osVersion.Major -eq 10 -and $osVersion.Minor -lt 0))
{
    Write-Message -Type ERROR -Message "This script requires Windows 10 or Windows 11"
    exit 1
}

# Check if running on Windows 11 (Build number 22000 or higher)
$isWindows11 = $osBuild -ge 22000
if ($isWindows11) {
    Write-Message -Message "Detected Windows 11 (Build $osBuild)"
} else {
    Write-Message -Message "Detected Windows 10 (Build $osBuild)"
}

Write-Message -Type WARNING -Message "Enabling features requires admin elevated privileges. Requesting elevated privileges..."

# Self-elevate the script if required
Request-ElevateScript -File $MyInvocation.MyCommand.Path

$RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if (! (Test-Path -Path $RegistryKeyPath)) 
{
    Write-Message -Message "Enable installing unsigned apps"
    New-Item -Path $RegistryKeyPath -ItemType Directory -Force
} else
{
    Write-Message -Type WARNING -Message "AppModelUnlock already set. Skipping.."
}

if (! (Get-ItemProperty -Path $RegistryKeyPath | Select -ExpandProperty AllowDevelopmentWithoutDevLicense))
{
    # Add registry value to enable Developer Mode
    Write-Message -Message "Enable developer mode"
    New-ItemProperty -Path $RegistryKeyPath -Name AllowDevelopmentWithoutDevLicense -PropertyType DWORD -Value 1
} else
{
    Write-Message -Type WARNING -Message "Dev mode already enabled. Skipping.."
}

$feature = Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online
if ($feature -and ($feature.State -eq "Disabled"))
{
    Write-Message -Message "Enable WSL"
    Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -All -LimitAccess -NoRestart
} else
{
    Write-Message -Type WARNING -Message "WSL already enabled. Skipping.."
}

$feature = Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online
if ($feature -and ($feature.State -eq "Disabled"))
{
    Write-Message -Message "Enable Virtual Machine Platform"
    Enable-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online -All -LimitAccess -NoRestart
} else
{
    Write-Message -Type WARNING -Message "Virtual Machine Platform already enabled. Skipping.."
}

$feature = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -Online
if ($feature -and ($feature.State -eq "Disabled"))
{
    Write-Message -Message "Enable Hyper-V"
    Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -Online -All -LimitAccess -NoRestart
} else
{
    Write-Message -Type WARNING -Message "Hyper-V already enabled. Skipping.."
}
