# Download the Ubuntu 22.04.3 LTS package
$distro = Read-Host -Prompt 'Enter the name of the distro to install (default: Ubuntu-22.04) '
$distro = $distro ? $distro : 'Ubuntu-22.04'

$wslListOutput = wsl --list --quiet
$distroList = $null

if ($null -ne $wslListOutput) {
    $distroList = $wslListOutput.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)
} else {
    $distroList = @()
}

# If the distro is already installed, ask if the user wants to reinstall it
if ($distroList -contains $distro) {
    $prompt = "$distro is already installed. Do you want to reinstall it? (y/n) "
    $reinstall = Read-Host -Prompt $prompt
}

# If the user wants to reinstall the distro, unregister it, otherwise exit
if ($reinstall -eq 'y') {
    wsl --unregister $distro
} elseif ($reinstall -eq 'n') {
    exit
}

# Install the distro
Write-Host "INFO: After the image is setup and you are in the linux console, please run 'exit' to finish the powershell script." -ForegroundColor Yellow
wsl --install $distro

# Set the distro as the default
wsl --set-default $distro

## Run the install-oh-my-zsh.sh script

# Define the Windows-style path
$windowsPath =  Join-Path (Split-Path -Parent $PSCommandPath) "install-oh-my-zsh.sh"

# Convert the drive letter to lowercase and remove the colon
$driveLetter = $windowsPath.Substring(0, 1).ToLower()
$windowsPath = $windowsPath.Substring(2)

# Replace the backslashes with forward slashes
$wslPath = $windowsPath -replace '\\', '/'

# Prepend the /mnt/ prefix and the drive letter
$wslPath = "/mnt/$driveLetter$wslPath"

# Execute the bash script
wsl bash $wslPath

# Start wsl
wsl --cd ~
