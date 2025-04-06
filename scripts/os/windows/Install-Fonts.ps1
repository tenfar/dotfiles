using module Message

#
# ░█▀▀░█▀█░█▀█░▀█▀░█▀▀
# ░█▀▀░█░█░█░█░░█░░▀▀█
# ░▀░░░▀▀▀░▀░▀░░▀░░▀▀▀
#

# Get Windows version
$osInfo = Get-CimInstance Win32_OperatingSystem
$osBuild = $osInfo.BuildNumber
$isWindows11 = $osBuild -ge 22000

# Windows font variables
$FONTS = 0x14
$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($FONTS)
$username = $env:UserName

# Create fonts directory if it doesn't exist
$userFontsPath = "C:\Users\$username\AppData\Local\Microsoft\Windows\Fonts"
if (!(Test-Path -Path $userFontsPath)) {
    New-Item -Path $userFontsPath -ItemType Directory -Force | Out-Null
    Write-Message -Message "Created user fonts directory at $userFontsPath"
}

# Loop through provided input directories
for ($i = 0; $i -lt $args.count; $i++) {
    Write-Message -Message "Checking $($args[$i]) for fonts that need to be installed..."
    
    # Current directory being checked
    $Path = $($args[$i])
    $FontItem = Get-Item -Path $Path
    
    # Get all font files
    $FontList = Get-ChildItem -Recurse -Path "$FontItem\*" -Include ('*.fon', '*.otf', '*.ttc', '*.ttf')
    $Fontdir = dir $Path

    foreach ($File in $FontList) {
        $name = $File.BaseName

        if (!($file.Name -match "pfb$")) {
            $try = $true
            $installedFonts = @(Get-ChildItem $userFontsPath | Where-Object {$_.PSIsContainer -eq $false} | Select-Object basename)
        
            foreach ($font in $installedFonts) {
                $font = $font -replace "_", ""
                $name = $name -replace "_", ""

                if ($font -match $name) {
                    $try = $false
                }
            }
            
            if ($try) {
                Write-Message -Message "Installing $name"
                
                # For Windows 11, we can use a more direct method
                if ($isWindows11) {
                    try {
                        # Copy font file to Windows Fonts folder
                        Copy-Item -Path $File.FullName -Destination "C:\Windows\Fonts" -Force
                        
                        # Add font to registry
                        $fontName = $File.BaseName
                        $fontFile = $File.Name
                        
                        # Create registry entries for the font
                        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
                        Set-ItemProperty -Path $regPath -Name "$fontName (TrueType)" -Value $fontFile -Type String -Force
                        
                        Write-Message -Type SUCCESS -Message "Successfully installed $name"
                    } catch {
                        Write-Message -Type ERROR -Message "Failed to install $name: $_"
                    }
                } else {
                    # Use the traditional method for Windows 10
                    $objFolder.CopyHere($File.FullName)
                    Write-Message -Type SUCCESS -Message "Successfully installed $name"
                }
            } else {
                Write-Message -Type WARNING -Message "Font $name already installed. Skipping..."
            }
        }
    }
}

# Refresh font cache
Write-Message -Message "Refreshing font cache..."
if ($isWindows11) {
    # Windows 11 specific font cache refresh
    Start-Process -FilePath "C:\Windows\System32\fontcache.exe" -ArgumentList "-f" -Wait
} else {
    # Windows 10 font cache refresh
    Start-Process -FilePath "C:\Windows\System32\fontcache.exe" -ArgumentList "-f" -Wait
}

Write-Message -Type SUCCESS -Message "Font installation completed"

