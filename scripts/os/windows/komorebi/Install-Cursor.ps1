using module Message
using module UserPreferencesMask

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

# Check what the current cursor is set to
$current_cursor = Get-ItemPropertyValue "HKCU:\Control Panel\Cursors" -Name "(Default)"

if ($current_cursor -eq "Catppuccin-Mocha-Blue-Cursors")
{
    Write-Message -Type WARNING  -Message 'Cursor already set. Skipping...'
} else
{
    Write-Message -Message 'Cursor not set. Installing cursor and setting...'

    infdefaultinstall.exe $args

    Set-itemproperty "HKCU:\Control Panel\Cursors" -Name "(Default)" -Value "Catppuccin-Mocha-Blue-Cursors"

    $RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser","$env:COMPUTERNAME")

    $RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors",$true)

    $RegCursors.SetValue("","Catppuccin-Mocha-Blue-Cursors")

    $RegCursors.SetValue("Scheme Source","1")

    # $RegCursors.SetValue("CursorBaseSize",0x20)

    $RegCursors.SetValue("AppStarting","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\working-in-background.ani")

    $RegCursors.SetValue("Arrow","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\normal-select.cur")

    $RegCursors.SetValue("Crosshair","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\precision-select.cur")

    $RegCursors.SetValue("Hand","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\link-select.cur")

    $RegCursors.SetValue("Help","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\help-select.cur")

    $RegCursors.SetValue("IBeam","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\text-select.cur")

    $RegCursors.SetValue("No","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\unavailable.cur")

    $RegCursors.SetValue("NWPen","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\handwriting.cur")

    $RegCursors.SetValue("SizeAll","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\move.cur")

    $RegCursors.SetValue("SizeNESW","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\diagonal-resize-2.cur")

    $RegCursors.SetValue("SizeNS","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\vertical-resize.cur")

    $RegCursors.SetValue("SizeNWSE","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\diagonal-resize-1.cur")

    $RegCursors.SetValue("SizeWE","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\horizontal-resize.cur")

    $RegCursors.SetValue("UpArrow","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\alt-select.cur")

    $RegCursors.SetValue("Wait","%SYSTEMROOT%\Cursors\Catppuccin-Mocha-Blue-Cursors\busy.ani")

    $RegCursors.Close()

    $RegConnect.Close()

    # Windows 11 specific cursor settings
    if ($isWindows11) {
        Write-Message -Message "Configuring Windows 11 specific cursor settings..."
        
        # Enable custom cursors in Windows 11
        $cursorSettingsPath = "HKCU:\Control Panel\Cursors"
        Set-ItemProperty -Path $cursorSettingsPath -Name "CursorScheme" -Value "Catppuccin-Mocha-Blue-Cursors"
        
        # Set cursor size (Windows 11 supports larger cursors)
        Set-ItemProperty -Path $cursorSettingsPath -Name "CursorBaseSize" -Value 32
        
        # Enable cursor shadows (Windows 11 feature)
        Set-ItemProperty -Path $cursorSettingsPath -Name "CursorShadow" -Value 1
        
        # Set cursor animation speed
        Set-ItemProperty -Path $cursorSettingsPath -Name "CursorAnimationSpeed" -Value 10
        
        # Apply cursor settings to all windows
        $explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
        if (Test-Path -Path $explorerPath) {
            Set-ItemProperty -Path $explorerPath -Name "CursorShadow" -Value 1
        }
        
        # Restart Explorer to apply changes
        Write-Message -Message "Restarting Explorer to apply cursor changes..."
        Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
        Start-Process "explorer"
    }

    Update-UserPreferencesMask
    
    Write-Message -Type SUCCESS -Message "Cursor installation completed"
}
