using module RegistryEntry
using module TestCommandExists
using module Message

$env:PSModulePath = "$PSHOME/Modules\"+";$SCRIPTS_DIR/os/windows/modules";

# Get Windows version
$osInfo = Get-CimInstance Win32_OperatingSystem
$osBuild = $osInfo.BuildNumber
$isWindows11 = $osBuild -ge 22000

#
# ░█▀▀░█▀▀░█▀█░█▀█░█▀█░░░█▀█░█▀█░█▀█░█▀▀
# ░▀▀█░█░░░█░█░█░█░█▀▀░░░█▀█░█▀▀░█▀▀░▀▀█
# ░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░░░░░▀░▀░▀░░░▀░░░▀▀▀
#
## 
# Install scoop
##
if (!(Test-Path -Path "$($env:USERPROFILE)/scoop/shims/scoop" -PathType Leaf))
{
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
} else
{
    Write-Host ""
    Write-Message -Type WARNING -Message "Scoop already installed. skipping..."
}

if (Test-CommandExists scoop)
{
    
    # buckets
    $scoop_buckets = @(
        'main', 'extras', 'versions'
    )

    foreach ($bucket in $scoop_buckets)
    {
        scoop bucket add $bucket
    }

    # scoops
    $scoop_apps = @(
        'sudo', 'bat', 'btop', 'fastfetch', 'pshazz', 'git-crypt', 'vcredist', '1password-cli',
        'secureuxtheme', '7tsp', 'archwsl', 'spicetify-cli', 'topgrade'
    )

    foreach ($app in $scoop_apps)
    {
        scoop install $app
    }

    # elevated installs
    sudo scoop install windowsdesktop-runtime-lts
} else
{
    Write-Message -Type WARNING  -Message "    Scoop not installed. Skipping scoop installs..."
}

#
# ░█░█░▀█▀░█▀█░█▀▀░█▀▀░▀█▀░░░█▀█░█▀█░█▀█░█▀▀
# ░█▄█░░█░░█░█░█░█░█▀▀░░█░░░░█▀█░█▀▀░█▀▀░▀▀█
# ░▀░▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░░▀░░░░▀░▀░▀░░░▀░░░▀▀▀
#
##
# Install winget
# https://github.com/microsoft/winget-cli/
##
if ( !(Test-CommandExists winget))
{
    Write-Host ""
    Write-Message  -Message "Installing winget"
    $download_url = "https://github.com/microsoft/winget-cli/releases/download/v1.4.10173/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    $download_save_file = "$($env:USERPROFILE)\Downloads\MicrosoftDesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    $wc.Downloadfile($download_url, $download_save_file)
    Add-AppXPackage -Path $($env:USERPROFILE)\Downloads\MicrosoftDesktopAppInstaller_8wekyb3d8bbwe.msixbundle
} else
{
    Write-Host ""
    Write-Message -Type WARNING  -Message "Winget already installed. Skipping..."
}

##
# Winget installations
##
if (Test-CommandExists winget)
{
    # Common apps for both Windows 10 and 11
    $common_apps = @(
        'MSYS2.MSYS2',
        'Microsoft.Powershell.Preview',
        'Microsoft.WindowsTerminal.Preview',
        'Bitsum.ProcessLasso',
        'Git.Git',
        'GitHub.GitHubDesktop',
        'Microsoft.VisualStudioCode',
        'Neovim.Neovim',
        'Microsoft.DotNet.SDK.7',
        'Microsoft.DotNet.Runtime.7',
        'Microsoft.DotNet.DesktopRuntime.7',
        'Mozilla.Firefox.DeveloperEdition',
        'AgileBits.1Password',
        'Microsoft.Teams',
        'AntibodySoftware.WizTree',
        'Notepad++.Notepad++',
        'Microsoft.Sysinternals.Autoruns',
        'Valve.Steam',
        'HeroicGamesLauncher.HeroicGamesLauncher',
        'Alacritty.Alacritty',
        'Rustlang.Rustup',
        'LLVM.LLVM',
        'CoreyButler.NVMforWindows',
        'JesseDuffield.lazygit'
    )

    # Windows 11 specific apps
    $win11_apps = @(
        'MicaForEveryone.MicaForEveryone',
        'StartIsBack.StartAllBack'
    )

    # Install common apps
    foreach ($app in $common_apps)
    {
        Write-Message -Message "    Installing $app..."
        winget install --accept-package-agreements --accept-source-agreements --silent --no-upgrade --id $app
    }

    # Install Windows 11 specific apps
    if ($isWindows11) {
        Write-Message -Message "Installing Windows 11 specific applications..."
        foreach ($app in $win11_apps)
        {
            Write-Message -Message "    Installing $app..."
            winget install --accept-package-agreements --accept-source-agreements --silent --no-upgrade --id $app
        }

        # Configure Windows 11 specific settings
        Write-Message -Message "Configuring Windows 11 specific settings..."
        
        # Configure MicaForEveryone
        $micaPath = "HKCU:\Software\MicaForEveryone"
        if (Test-Path -Path $micaPath) {
            Set-ItemProperty -Path $micaPath -Name "RunOnStartup" -Value 1
            Set-ItemProperty -Path $micaPath -Name "GlobalMica" -Value 1
            Set-ItemProperty -Path $micaPath -Name "GlobalMicaColor" -Value "#202020"
            Set-ItemProperty -Path $micaPath -Name "GlobalMicaOpacity" -Value 100
        }
        
        # Configure StartAllBack
        $startAllBackPath = "HKCU:\Software\StartIsBack"
        if (Test-Path -Path $startAllBackPath) {
            Set-ItemProperty -Path $startAllBackPath -Name "StartMenuWin11" -Value 1
            Set-ItemProperty -Path $startAllBackPath -Name "StartMenuWin11Style" -Value 1
            Set-ItemProperty -Path $startAllBackPath -Name "StartMenuWin11Classic" -Value 1
            Set-ItemProperty -Path $startAllBackPath -Name "TaskbarWin11" -Value 1
            Set-ItemProperty -Path $startAllBackPath -Name "TaskbarWin11Style" -Value 1
            Set-ItemProperty -Path $startAllBackPath -Name "TaskbarWin11Classic" -Value 1
        }
    }
} else
{
    Write-Message -Type WARNING -Message "    Winget not installed. Skipping winget installs..."
}

# Install UltraUXThemePatcher for Windows 11
if ($isWindows11) {
    Write-Message -Message "Installing UltraUXThemePatcher for Windows 11..."
    
    # Download UltraUXThemePatcher
    $ultraUXThemePatcherUrl = "https://github.com/niivu/Windows-11-themes/releases/download/UltraUXThemePatcher/UltraUXThemePatcher.exe"
    $ultraUXThemePatcherPath = "$($env:USERPROFILE)\Downloads\UltraUXThemePatcher.exe"
    
    if (!(Test-Path -Path $ultraUXThemePatcherPath)) {
        $wc.Downloadfile($ultraUXThemePatcherUrl, $ultraUXThemePatcherPath)
        Write-Message -Message "Downloaded UltraUXThemePatcher"
    }
    
    # Run UltraUXThemePatcher with elevated privileges
    if (Test-Path -Path $ultraUXThemePatcherPath) {
        Write-Message -Message "Running UltraUXThemePatcher (requires admin privileges)..."
        Start-Process -FilePath $ultraUXThemePatcherPath -Verb RunAs -Wait
        Write-Message -Type SUCCESS -Message "UltraUXThemePatcher installed successfully"
    } else {
        Write-Message -Type ERROR -Message "Failed to download UltraUXThemePatcher"
    }
}

Write-Message -Type SUCCESS -Message "Program installation completed"

