using module Message
using module RegistryEntry
using module TestCommandExists

$env:PSModulePath = "$PSHOME/Modules\"+";$SCRIPTS_DIR/os/windows/modules";

#
# ░▀█▀░█░█░█▀▀░█▄█░▀█▀░█▀█░█▀▀
# ░░█░░█▀█░█▀▀░█░█░░█░░█░█░█░█
# ░░▀░░▀░▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀▀▀
#

# Get Windows version
$osInfo = Get-CimInstance Win32_OperatingSystem
$osBuild = $osInfo.BuildNumber
$isWindows11 = $osBuild -ge 22000

##
# Winget installations
##
if (Test-CommandExists winget)
{
    # Common apps for both Windows 10 and 11
    $common_apps = @(
        'JanDeDobbeleer.OhMyPosh',
        'Rainmeter.Rainmeter',
        'LGUG2Z.komorebi',
        'LGUG2Z.whkd'
    )

    # Windows 11 specific apps
    $win11_apps = @(
        'MicaForEveryone.MicaForEveryone',
        'StartIsBack.StartAllBack'
    )

    # Combine apps based on Windows version
    $winget_apps = $common_apps
    if ($isWindows11) {
        $winget_apps += $win11_apps
        Write-Message -Message "Installing Windows 11 specific applications..."
    } else {
        Write-Message -Message "Installing Windows 10 applications..."
    }

    foreach ($app in $winget_apps)
    {
        Write-Message -Message "Installing $app..."
        winget install --accept-package-agreements --accept-source-agreements --silent --no-upgrade --id $app
    }
} else
{
    Write-Message -Type WARNING -Message "Winget not installed. Skipping winget installs..."
}

##
# Win 11 Theme Patcher
# https://mhoefs.eu/software_count.php
##
if ($isWindows11) {
    if (!(Test-Path -Path "$($env:USERPROFILE)\Downloads\UltraUXThemePatcher.exe" -PathType Leaf))
    {
        Write-Message -Message "Downloading UltraUXThemePatcher for Windows 11..."
        $postParams = @{Uxtheme='UltraUXThemePatcher';id='Uxtheme'}
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri https://mhoefs.eu/software_count.php -OutFile "$($env:USERPROFILE)\Downloads\UltraUXThemePatcher.exe" -Method POST -Body $postParams
        Write-Message -Message "Downloaded to $($env:USERPROFILE)\Downloads\UltraUXThemePatcher.exe"
        Write-Message -Type WARNING -Message "Please run UltraUXThemePatcher to enable custom themes on Windows 11"
    } else
    {
        Write-Message -Type WARNING -Message "UltraUXThemePatcher already downloaded. Skipping..."
        Write-Message -Type WARNING -Message "Please run UltraUXThemePatcher to enable custom themes on Windows 11"
    }
}

## Set komorebi to run on startup
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" 

Write-Message -Message "Setting komorebi to start on login"
Set-RegistryEntry -Key 'KomorebicOnLogin' -Type "String" -Value 'pwsh -Command "komorebic start --await-configuration"' -Path $RegPath

# Additional Windows 11 specific configurations
if ($isWindows11) {
    Write-Message -Message "Configuring Windows 11 specific settings..."
    
    # Enable MicaForEveryone
    $RegPathMica = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    Set-RegistryEntry -Key 'MicaForEveryone' -Type "String" -Value 'MicaForEveryone.exe' -Path $RegPathMica
    
    # Configure StartAllBack
    $RegPathStartAllBack = "HKCU:\Software\StartAllBack"
    if (!(Test-Path -Path $RegPathStartAllBack)) {
        New-Item -Path $RegPathStartAllBack -Force | Out-Null
    }
    Set-ItemProperty -Path $RegPathStartAllBack -Name "StartMenuStyle" -Value 1 -Type DWORD -Force
    Set-ItemProperty -Path $RegPathStartAllBack -Name "TaskbarStyle" -Value 1 -Type DWORD -Force
}
