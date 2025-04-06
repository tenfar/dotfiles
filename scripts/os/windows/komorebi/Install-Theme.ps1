using module Message

#
# ░▀█▀░█░█░█▀▀░█▄█░▀█▀░█▀█░█▀▀
# ░░█░░█▀█░█▀▀░█░█░░█░░█░█░█░█
# ░░▀░░▀░▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀▀▀
#

# Get Windows version
$osInfo = Get-CimInstance Win32_OperatingSystem
$osBuild = $osInfo.BuildNumber
$isWindows11 = $osBuild -ge 22000

# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
{
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000)
    {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

# Windows themes variables
$RESOURCES = "C:\Windows\Resources\Themes\"
$objShell = New-Object -ComObject Shell.Application

# Loop through provided input directories
for ( $i = 0; $i -lt $args.count; $i++ )
{
    # Current directory being checked
    $Path=$($args[$i])
    
    Write-Message -Message "Installing $Path"

    Copy-Item -Path $Path -Destination $RESOURCES -Recurse -Force

    Write-Message -Type SUCCESS -Message "Successfully installed theme."
}

# Enable themes in Windows 11
if ($isWindows11) {
    Write-Message -Message "Configuring Windows 11 theme settings..."
    
    # Enable themes tab in personalization
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    if (!(Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "NoThemesTab" -Value 0 -Type DWORD -Force
    
    # Enable classic theme support
    $regPathTheme = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (!(Test-Path -Path $regPathTheme)) {
        New-Item -Path $regPathTheme -Force | Out-Null
    }
    Set-ItemProperty -Path $regPathTheme -Name "AppsUseLightTheme" -Value 0 -Type DWORD -Force
    Set-ItemProperty -Path $regPathTheme -Name "SystemUsesLightTheme" -Value 0 -Type DWORD -Force
}

# Apply theme if Catppuccin Mocha is installed
if (Test-Path -Path "$RESOURCES\Catppuccin-Mocha.theme" -PathType Leaf)
{
    $currentTheme=(Get-ItemProperty -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\ -Name "CurrentTheme").CurrentTheme
    if ($currentTheme -eq "$RESOURCES\Catppuccin-Mocha.theme")
    {
        Write-Message -Type WARNING -Message "Theme already set to Catppuccin Mocha. Skipping..."
    } else
    {
        Write-Message -Message "Setting theme to Catppuccin Mocha"
        start-process -filepath "$RESOURCES\Catppuccin-Mocha.theme"
        Start-Sleep -Seconds 3
        taskkill /im "systemsettings.exe" /f
    }
} else
{
    Write-Message -Type ERROR -Message "Catppuccin Mocha not found in $RESOURCES\. Skipping..."
}

# Restart Explorer to apply changes
Write-Message -Message "Restarting Explorer to apply theme changes..."
Stop-Process -Name "explorer" -Force
Start-Process "explorer"
