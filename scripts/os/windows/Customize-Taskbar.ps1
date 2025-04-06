using module Message
using module RegistryEntry

#
# ░▀█▀░█░█░█▀▀░█▄█░▀█▀░█▀█░█▀▀
# ░░█░░█▀█░█▀▀░█░█░░█░░█░█░█░█
# ░░▀░░▀░▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀▀▀
#
##
# Update Windows Taskbar
##

# Get Windows version
$osInfo = Get-CimInstance Win32_OperatingSystem
$osBuild = $osInfo.BuildNumber
$isWindows11 = $osBuild -ge 22000

if ($isWindows11) {
    Write-Message -Message "Configuring Windows 11 taskbar..."
    
    # Windows 11 specific registry paths
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $RegPathTaskbar = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
    
    # Taskbar settings for Windows 11
    Write-Message -Type WARNING -Message "Configuring taskbar settings..."
    Set-RegistryEntry -Key 'TaskbarAl' -Type "DWORD" -Value '0' -Path $RegPath  # Left align taskbar
    Set-RegistryEntry -Key 'TaskbarMn' -Type "DWORD" -Value '0' -Path $RegPath  # Hide Chat
    Set-RegistryEntry -Key 'TaskbarDa' -Type "DWORD" -Value '0' -Path $RegPath  # Hide Widgets
    Set-RegistryEntry -Key 'ShowTaskViewButton' -Type "DWORD" -Value '0' -Path $RegPath  # Hide Task View
    
    # Search settings
    $RegPathSearch = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    Set-RegistryEntry -Key 'SearchboxTaskbarMode' -Type "DWORD" -Value '0' -Path $RegPathSearch  # Hide Search
    
    # Additional Windows 11 specific settings
    $RegPathExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-RegistryEntry -Key 'HideFileExt' -Type "DWORD" -Value '0' -Path $RegPathExplorer  # Show file extensions
    Set-RegistryEntry -Key 'Hidden' -Type "DWORD" -Value '1' -Path $RegPathExplorer  # Show hidden files
} else {
    Write-Message -Message "Configuring Windows 10 taskbar..."
    
    # Windows 10 registry paths
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    
    # Taskbar settings for Windows 10
    Write-Message -Type WARNING -Message "Configuring taskbar settings..."
    Set-RegistryEntry -Key 'TaskbarAl' -Type "DWORD" -Value '0' -Path $RegPath  # Left align taskbar
    Set-RegistryEntry -Key 'TaskbarMn' -Type "DWORD" -Value '0' -Path $RegPath  # Hide Chat
    Set-RegistryEntry -Key 'TaskbarDa' -Type "DWORD" -Value '0' -Path $RegPath  # Hide Widgets
    Set-RegistryEntry -Key 'ShowTaskViewButton' -Type "DWORD" -Value '0' -Path $RegPath  # Hide Task View
    
    # Search settings
    $RegPathSearch = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    Set-RegistryEntry -Key 'SearchboxTaskbarMode' -Type "DWORD" -Value '0' -Path $RegPathSearch  # Hide Search
}

# Restart Explorer to apply changes
Write-Message -Message "Restarting Explorer to apply changes..."
Stop-Process -Name "explorer" -Force
Start-Process "explorer"
