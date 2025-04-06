using module Message

# 
# ░█▀█░█▀▄░█▀▀░█▀█
# ░█▀▀░█▀▄░█▀▀░█▀▀
# ░▀░░░▀░▀░▀▀▀░▀░░
#

# Get Windows version
$osInfo = Get-CimInstance Win32_OperatingSystem
$osBuild = $osInfo.BuildNumber
$isWindows11 = $osBuild -ge 22000

# Define paths
$DOTFILES_MODULES_PATH = "$SCRIPTS_DIR/os/windows/modules"
$DOCUMENTS_PATH = Get-ItemPropertyValue -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name "Personal" -ErrorAction SilentlyContinue
$USER_MODULES_PATH = "$DOCUMENTS_PATH/WindowsPowerShell/Modules/"

# Create modules directory if it doesn't exist
if (!(Test-Path -Path $USER_MODULES_PATH)) {
    New-Item -Path $USER_MODULES_PATH -ItemType Directory -Force | Out-Null
    Write-Message -Message "Created PowerShell modules directory at $USER_MODULES_PATH"
}

# Get list of modules to install
$ModuleList = Get-ChildItem -Path "$DOTFILES_MODULES_PATH\*"

# Install modules
foreach ($module in $ModuleList) {
    $moduleName = $module.BaseName
    $modulePath = "$USER_MODULES_PATH$moduleName"
    
    # Check if module is already installed
    if (Test-Path -Path $modulePath) {
        Write-Message -Type WARNING -Message "$moduleName already installed. Skipping..."
    } else {
        Write-Message -Message "Installing $moduleName module"
        
        # Create module directory
        New-Item -Path $modulePath -ItemType Directory -Force | Out-Null
        
        # Copy module files
        Copy-Item -Path "$module\*" -Destination $modulePath -Recurse -Force
        
        # For Windows 11, we need to ensure the module is properly registered
        if ($isWindows11) {
            # Check if module manifest exists
            $manifestPath = "$modulePath\$moduleName.psd1"
            if (Test-Path -Path $manifestPath) {
                # Import module to register it
                Import-Module -Name $modulePath -Force -ErrorAction SilentlyContinue
                Write-Message -Type SUCCESS -Message "Successfully installed and registered $moduleName module"
            } else {
                Write-Message -Type WARNING -Message "Module manifest not found for $moduleName. Module may not be properly registered."
            }
        } else {
            Write-Message -Type SUCCESS -Message "Successfully installed $moduleName module"
        }
    }
}

# Update PowerShell profile if needed
$profilePath = $PROFILE.CurrentUserCurrentHost
if (!(Test-Path -Path $profilePath)) {
    New-Item -Path $profilePath -ItemType File -Force | Out-Null
    Write-Message -Message "Created PowerShell profile at $profilePath"
    
    # Add module import statements to profile
    $profileContent = @"
# Import custom modules
`$env:PSModulePath = "`$PSHOME/Modules/"+";$SCRIPTS_DIR/os/windows/modules";
"@
    
    Set-Content -Path $profilePath -Value $profileContent
    Write-Message -Message "Added module path to PowerShell profile"
}

Write-Message -Type SUCCESS -Message "Module installation completed"
