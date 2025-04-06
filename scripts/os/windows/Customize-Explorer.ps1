using module Message
using module RegistryEntry

#
# ░▀█▀░█░█░█▀▀░█▄█░▀█▀░█▀█░█▀▀
# ░░█░░█▀█░█▀▀░█░█░░█░░█░█░█░█
# ░░▀░░▀░▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀▀▀
#
##
# Update Windows Explorer Settings
##

# Get Windows version
$osInfo = Get-CimInstance Win32_OperatingSystem
$osBuild = $osInfo.BuildNumber
$isWindows11 = $osBuild -ge 22000

# Common registry paths
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$RegPathExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"

# Common settings for both Windows 10 and 11
Write-Message -Message "Configuring common Explorer settings..."
Set-RegistryEntry -Key 'HideFileExt' -Type "DWORD" -Value '0' -Path $RegPath  # Show file extensions
Set-RegistryEntry -Key 'Hidden' -Type "DWORD" -Value '1' -Path $RegPath  # Show hidden files

if ($isWindows11) {
    Write-Message -Message "Configuring Windows 11 specific Explorer settings..."
    
    # Windows 11 specific settings
    Set-RegistryEntry -Key 'LaunchTo' -Type "DWORD" -Value '1' -Path $RegPath  # Open Explorer to This PC
    Set-RegistryEntry -Key 'NavPaneExpandMode' -Type "DWORD" -Value '1' -Path $RegPath  # Expand navigation pane
    
    # Disable modern search experience
    $RegPathSearch = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    Set-RegistryEntry -Key 'SearchboxTaskbarMode' -Type "DWORD" -Value '0' -Path $RegPathSearch
    
    # Configure Quick Access settings
    Set-RegistryEntry -Key 'ShowRecent' -Type "DWORD" -Value '0' -Path $RegPath  # Hide recent files
    Set-RegistryEntry -Key 'ShowFrequent' -Type "DWORD" -Value '0' -Path $RegPath  # Hide frequent files
    
    # Configure folder options
    Set-RegistryEntry -Key 'SeparateProcess' -Type "DWORD" -Value '1' -Path $RegPath  # Launch folder windows in a separate process
    Set-RegistryEntry -Key 'AlwaysShowMenus' -Type "DWORD" -Value '1' -Path $RegPath  # Always show menus
} else {
    Write-Message -Message "Configuring Windows 10 specific Explorer settings..."
    
    # Windows 10 specific settings
    Set-RegistryEntry -Key 'LaunchTo' -Type "DWORD" -Value '1' -Path $RegPath  # Open Explorer to This PC
    Set-RegistryEntry -Key 'NavPaneExpandMode' -Type "DWORD" -Value '1' -Path $RegPath  # Expand navigation pane
}

# Restart Explorer to apply changes
Write-Message -Message "Restarting Explorer to apply changes..."
Stop-Process -Name "explorer" -Force
Start-Process "explorer"
