using module Message
using module ConfigMap
using module FileCommands

#
# ░█▀▀░█▀█░█▀█░█▀▀░▀█▀░█▀▀░█░█░█▀▄░█▀█░▀█▀░▀█▀░█▀█░█▀█
# ░█░░░█░█░█░█░█▀▀░░█░░█░█░█░█░█▀▄░█▀█░░█░░░█░░█░█░█░█
# ░▀▀▀░▀▀▀░▀░▀░▀░░░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀░▀░░▀░░▀▀▀░▀▀▀░▀░▀
#

# Get Windows version
$osInfo = Get-CimInstance Win32_OperatingSystem
$osBuild = $osInfo.BuildNumber
$isWindows11 = $osBuild -ge 22000

# Powershell Variables
$timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
$ConfigMap = Get-ConfigMap

# Create Windows 11 specific configurations if needed
if ($isWindows11) {
    Write-Message -Message "Configuring Windows 11 specific settings..."
    
    # Windows 11 registry paths
    $RegPathExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $RegPathPersonalize = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    
    # Enable dark mode
    if (!(Test-Path -Path $RegPathPersonalize)) {
        New-Item -Path $RegPathPersonalize -Force | Out-Null
    }
    Set-ItemProperty -Path $RegPathPersonalize -Name "AppsUseLightTheme" -Value 0 -Type DWORD -Force
    Set-ItemProperty -Path $RegPathPersonalize -Name "SystemUsesLightTheme" -Value 0 -Type DWORD -Force
    
    # Configure taskbar settings
    if (!(Test-Path -Path $RegPathExplorer)) {
        New-Item -Path $RegPathExplorer -Force | Out-Null
    }
    Set-ItemProperty -Path $RegPathExplorer -Name "TaskbarAl" -Value 0 -Type DWORD -Force  # Left align taskbar
    Set-ItemProperty -Path $RegPathExplorer -Name "TaskbarMn" -Value 0 -Type DWORD -Force  # Hide Chat
    Set-ItemProperty -Path $RegPathExplorer -Name "TaskbarDa" -Value 0 -Type DWORD -Force  # Hide Widgets
    Set-ItemProperty -Path $RegPathExplorer -Name "ShowTaskViewButton" -Value 0 -Type DWORD -Force  # Hide Task View
}

# Loop through provided input directories
foreach ($config in $ConfigMap) {   
    if ($config.RequiresUnlock -eq $true -and $GIT_CRYPT_LOCKED -eq $true) {
        Write-Message -Type WARNING -Message (-join($config.Source, " is encrypted. Skipping..."))
        continue
    } 

    $backupFolderPath = (-join(${env:USERPROFILE},"\.config\dotfiles-backup\",$timestamp).Replace("/","\"))
    $destinationExists = Test-Path -Path $config.Destination

    if ($destinationExists -eq $true) {
        if ((get-item $config.Destination).Attributes.ToString() -match "ReparsePoint") {
            Write-Message -Type WARNING -Message (-join($config.Destination, " is already a symbolic link. Skipping..."))
            Write-Message -Type ERROR -Message "If you'd like to replace this location... delete your existing link and run again."
            continue
        } 

        Backup-Files -BackupFolderPath $backupFolderPath -Target $config.Destination
        
        if ($config.ReplaceExisting) {
            if ($config.CreateSymbolicLink -eq $true) {
                Write-Message -Message (-join("Deleting ", $config.Destination))
                Remove-Item -Path $config.Destination -Recurse -Force
            }
        } else {
            Write-Message -Type WARNING -Message "Config already exists. Skipping..."
            continue
        }
    } 

    $destinationFolderPath = Split-Path -parent $config.Destination
    
    if ($config.CreateSymbolicLink -eq $true) {
        New-SymbolicLink -Path $config.Destination -Target $config.Source
    } else {
        Write-Message -Message (-join("Copying ", $config.Source, " files to ", $destinationFolderPath))

        New-Item -ItemType Directory -Force -Path $destinationFolderPath

        Copy-Item -Path $config.Source -Destination $config.Destination -Recurse -Force
        
        # TODO: Move to komorebi specific script 
        if ($config.Source -match "btop.conf") {
            $regex = "color_theme = .*"
            $replacement = "color_theme = catppuccin_macchiato"

            (Get-Content $config.Destination) | 
                ForEach-Object { $_ -replace $regex, $replacement } |
                Set-Content $config.Destination
        }
    }
}

# Apply Windows 11 specific configurations after copying files
if ($isWindows11) {
    Write-Message -Message "Applying Windows 11 specific configurations..."
    
    # Restart Explorer to apply changes
    Write-Message -Message "Restarting Explorer to apply changes..."
    Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
    Start-Process "explorer"
}
