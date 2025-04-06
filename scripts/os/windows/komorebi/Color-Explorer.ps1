using module Message
using module RegistryEntry

#
# ░▀█▀░█░█░█▀▀░█▄█░▀█▀░█▀█░█▀▀
# ░░█░░█▀█░█▀▀░█░█░░█░░█░█░█░█
# ░░▀░░▀░▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀▀▀
#

# Get Windows version
$osInfo = Get-CimInstance Win32_OperatingSystem
$osBuild = $osInfo.BuildNumber
$isWindows11 = $osBuild -ge 22000

if ($isWindows11) {
    Write-Message -Message "Configuring Windows 11 color settings..."
    
    ##
    # Windows 11 Accent Color Settings
    # [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent]
    ##
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"
    
    Write-Message -Message 'Setting Windows 11 accent colors...'
    
    # AccentPalette (Catppuccin Mocha theme colors)
    $binary = '51,58,84,ff,43,49,6e,ff,3a,3f,5e,ff,30,34,4e,ff,26,2a,3f,ff,1d,1f,2f,ff,0f,10,19,ff,88,17,98,00'
    $hexified = $binary.Split(',') | ForEach-Object { "0x$_" }
    [string]$hexified = $hexified -join ','
    Set-RegistryEntry -Key 'AccentPalette' -Type "BINARY" -Value $hexified -Path $RegPath
    
    # AccentColor Menu
    Set-RegistryEntry -Key 'AccentColorMenu' -Type "DWORD" -Value '0xff4e3430' -Path $RegPath
    
    # MotionAccentId
    Set-RegistryEntry -Key 'MotionAccentId_v1.00' -Type "DWORD" -Value '0x000000db' -Path $RegPath
    
    # Start Color Menu
    Set-RegistryEntry -Key 'StartColorMenu' -Type "DWORD" -Value '0xff3f2a26' -Path $RegPath
    
    ##
    # Windows 11 DWM Settings
    # [HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
    ##
    $RegPath = "HKCU:\Software\Microsoft\Windows\DWM"
    
    # Enable window composition
    Set-RegistryEntry -Key 'Composition' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Enable glass effect
    Set-RegistryEntry -Key 'ColorizationGlassAttribute' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Set accent color
    Set-RegistryEntry -Key 'AccentColor' -Type "DWORD" -Value '0xff4e3430' -Path $RegPath
    
    # Enable color prevalence
    Set-RegistryEntry -Key 'ColorPrevalence' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Enable Aero Peek
    Set-RegistryEntry -Key 'EnableAeroPeek' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Set colorization color
    Set-RegistryEntry -Key 'ColorizationColor' -Type "DWORD" -Value '0xc430344e' -Path $RegPath
    
    # Set colorization balance
    Set-RegistryEntry -Key 'ColorizationColorBalance' -Type "DWORD" -Value '0x00000059' -Path $RegPath
    
    # Set afterglow color
    Set-RegistryEntry -Key 'ColorizationAfterglow' -Type "DWORD" -Value '0xc430344e' -Path $RegPath
    
    # Set afterglow balance
    Set-RegistryEntry -Key 'ColorizationAfterglowBalance' -Type "DWORD" -Value '0x0000000a' -Path $RegPath
    
    # Set blur balance
    Set-RegistryEntry -Key 'ColorizationBlurBalance' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Enable window colorization
    Set-RegistryEntry -Key 'EnableWindowColorization' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    ##
    # Windows 11 Personalization Settings
    # [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize]
    ##
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    
    # Enable transparency
    Write-Message -Message 'Enabling transparency...'
    Set-RegistryEntry -Key 'EnableTransparency' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Enable colors on start and taskbar
    Write-Message -Message 'Enabling color on start and taskbar...'
    Set-RegistryEntry -Key 'ColorPrevalence' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Set dark mode
    Write-Message -Message 'Setting dark mode...'
    Set-RegistryEntry -Key 'AppsUseLightTheme' -Type "DWORD" -Value '0x00000000' -Path $RegPath
    Set-RegistryEntry -Key 'SystemUsesLightTheme' -Type "DWORD" -Value '0x00000000' -Path $RegPath
    
    # Additional Windows 11 specific settings
    $RegPathExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-RegistryEntry -Key 'TaskbarAl' -Type "DWORD" -Value '0x00000000' -Path $RegPathExplorer  # Left align taskbar
} else {
    Write-Message -Message "Configuring Windows 10 color settings..."
    
    ##
    # Windows 10 Accent Color Settings
    # [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent]
    ##
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"
    
    Write-Message -Message 'Setting Windows 10 accent colors...'
    
    # AccentPalette (Catppuccin Mocha theme colors)
    $binary = '51,58,84,ff,43,49,6e,ff,3a,3f,5e,ff,30,34,4e,ff,26,2a,3f,ff,1d,1f,2f,ff,0f,10,19,ff,88,17,98,00'
    $hexified = $binary.Split(',') | ForEach-Object { "0x$_" }
    [string]$hexified = $hexified -join ','
    Set-RegistryEntry -Key 'AccentPalette' -Type "BINARY" -Value $hexified -Path $RegPath
    
    # AccentColor Menu
    Set-RegistryEntry -Key 'AccentColorMenu' -Type "DWORD" -Value '0xff4e3430' -Path $RegPath
    
    # MotionAccentId
    Set-RegistryEntry -Key 'MotionAccentId_v1.00' -Type "DWORD" -Value '0x000000db' -Path $RegPath
    
    # Start Color Menu
    Set-RegistryEntry -Key 'StartColorMenu' -Type "DWORD" -Value '0xff3f2a26' -Path $RegPath
    
    ##
    # Windows 10 DWM Settings
    # [HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
    ##
    $RegPath = "HKCU:\Software\Microsoft\Windows\DWM"
    
    # Enable window composition
    Set-RegistryEntry -Key 'Composition' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Enable glass effect
    Set-RegistryEntry -Key 'ColorizationGlassAttribute' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Set accent color
    Set-RegistryEntry -Key 'AccentColor' -Type "DWORD" -Value '0xff4e3430' -Path $RegPath
    
    # Enable color prevalence
    Set-RegistryEntry -Key 'ColorPrevalence' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Enable Aero Peek
    Set-RegistryEntry -Key 'EnableAeroPeek' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Set colorization color
    Set-RegistryEntry -Key 'ColorizationColor' -Type "DWORD" -Value '0xc430344e' -Path $RegPath
    
    # Set colorization balance
    Set-RegistryEntry -Key 'ColorizationColorBalance' -Type "DWORD" -Value '0x00000059' -Path $RegPath
    
    # Set afterglow color
    Set-RegistryEntry -Key 'ColorizationAfterglow' -Type "DWORD" -Value '0xc430344e' -Path $RegPath
    
    # Set afterglow balance
    Set-RegistryEntry -Key 'ColorizationAfterglowBalance' -Type "DWORD" -Value '0x0000000a' -Path $RegPath
    
    # Set blur balance
    Set-RegistryEntry -Key 'ColorizationBlurBalance' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Enable window colorization
    Set-RegistryEntry -Key 'EnableWindowColorization' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    ##
    # Windows 10 Personalization Settings
    # [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize]
    ##
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    
    # Enable transparency
    Write-Message -Message 'Enabling transparency...'
    Set-RegistryEntry -Key 'EnableTransparency' -Type "DWORD" -Value '0x00000001' -Path $RegPath
    
    # Enable colors on start and taskbar
    Write-Message -Message 'Enabling color on start and taskbar...'
    Set-RegistryEntry -Key 'ColorPrevalence' -Type "DWORD" -Value '0x00000001' -Path $RegPath
}

# Restart explorer
Write-Message -Type WARNING -Message 'Restarting explorer to apply changes...'
Stop-Process -ProcessName explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer
