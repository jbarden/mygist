# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine


[CmdletBinding()]
Param
(
    # Will run everything
    [switch]$All,

    # Bootstrap PS Modules
    [switch]$Bootstrap,

    # Bootstrap VSCode
    [switch]$VSCode,

    # Install Fork (GIT CLient)
    [switch]$Fork,

    # Bootstrap Azure CLI
    [switch]$AzureCLI,

    # Create the default directories (if a list is supplied below, they will also be created, otherwise, a default list will be created)
    [switch]$CreateDirectories,

    # Installs applications like Notepad++, WinMerge, 7Zip, etc.
    [switch]$RecommendedApplications,

    # Installs the full Visual Studio 2022 - Professional or Enterprise
    [switch]$VisualStudio,

    # Visual Studio Code installation
    [parameter()]
    [ValidateSet("64-bit", "32-bit")]
    [string]$Architecture = "64-bit",

    [parameter()]
    [ValidateSet("stable", "insider")]
    [string]$BuildEdition = "stable",

    [parameter()]
    [ValidateSet("enterprise", "professional")]
    [string]$VisualStudioEdition = "enterprise",

    [Parameter()]
    [ValidateNotNull()]
    [string[]]$AdditionalExtensions = @(),

    [Parameter()]
    [ValidateNotNull()]
    [string[]]$Directories = @()
)

$ErrorActionPreference = 'Stop'

switch ($Architecture)
{
    "64-bit"
    {
        if ((Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture -eq "64-bit")
        {
            $codePath = $env:ProgramFiles
            $bitVersion = "win32-x64"
        }
        else
        {
            $codePath = $env:ProgramFiles
            $bitVersion = "win32"
            $Architecture = "32-bit"
        }
        break;
    }
    "32-bit"
    {
        if ((Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture -eq "32-bit")
        {
            $codePath = $env:ProgramFiles
            $bitVersion = "win32"
        }
        else
        {
            $codePath = ${env:ProgramFiles(x86)}
            $bitVersion = "win32"
        }
        break;
    }
}

if ($Bootstrap.IsPresent -or $All.IsPresent) {
    Get-PackageProvider -Name Nuget -ForceBootstrap | Out-Null
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    if (-not (Get-Module -Name PSDepend -ListAvailable)) {
        Write-Host "`nInstalling PSDepend..."
        Install-Module -Name PSDepend -Repository PSGallery
    }

    if (((Get-Module -Name Pester -ListAvailable).Version.Major) -lt 5) {
        Write-Host "`nUpdating old version of Pester..." -ForegroundColor Yellow
        #Uninstall-Module -Name Pester -AllVersions -Force
        $module = "C:\Program Files\WindowsPowerShell\Modules\Pester"
        takeown /F $module /A /R
        icacls $module /reset
        icacls $module /grant "*S-1-5-32-544:F" /inheritance:d /T
        Remove-Item -Path $module -Recurse -Force -Confirm:$false

        Install-Module -Name Pester -Force
    }
    Write-Host "`nImporting PSDepend..."
    Import-Module -Name PSDepend -Verbose:$false
    Write-Host "`nRunning Invoke-PSDepend..."
    Invoke-PSDepend -Path './requirements.psd1' -Install -Import -Force -WarningAction SilentlyContinue
}

if ($VSCode.IsPresent -or $All.IsPresent) 
{
    Write-Host "`nChecking whether VS-Code is installed..." 
    if (($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows)
    {
        switch ($BuildEdition)
        {
            "Stable"
            {
                $codeCmdPath = "$codePath\Microsoft VS Code\bin\code.cmd"
                $appName = "Visual Studio Code ($($Architecture))"
                break;
            }
            "Insider"
            {
                $codeCmdPath = "$codePath\Microsoft VS Code Insiders\bin\code-insiders.cmd"
                $appName = "Visual Studio Code - Insiders Edition ($($Architecture))"
                break;
            }
        }
        
        if(((Get-CimInstance -ClassName Win32_OperatingSystem).Name).Contains("Windows 11")){
            $codeCmdPath = "C:\Program Files\Microsoft VS Code\bin\code.cmd"
            Write-Host "`nReset codeCmdPath to: $codeCmdPath..." -ForegroundColor Green
        } else {
            Write-Host "`nCodeCmdPath is: $codeCmdPath..." -ForegroundColor Red
        }

        try
        {
            $ProgressPreference = 'SilentlyContinue'
            if (!(Test-Path $codeCmdPath))
            {
                Write-Host "`nDownloading latest $appName..." -ForegroundColor Yellow
                Write-Host "`n$env:TEMP\vscode-$($BuildEdition).exe..." -ForegroundColor Yellow
                Remove-Item -Force "$env:TEMP\vscode-$($BuildEdition).exe" -ErrorAction SilentlyContinue
                Invoke-WebRequest -Uri "https://update.code.visualstudio.com/latest/$($bitVersion)/$($BuildEdition)" -OutFile "$env:TEMP\vscode-$($BuildEdition).exe"
    
                Write-Host "`nInstalling $appName..." -ForegroundColor Yellow
                Start-Process -Wait "$env:TEMP\vscode-$($BuildEdition).exe" -ArgumentList /silent, /mergetasks=!runcode
            }
            else
            {
                Write-Host "`n$appName is already installed." -ForegroundColor Yellow
            }

            $extensions = @("ms-azuretools.vscode-bicep") + @("ms-vscode.powershell") + @("ms-dotnettools.csharp") + @("christian-kohler.npm-intellisense") + @("ms-azuretools.vscode-docker") + @("vue.vscode-typescript-vue-plugin") + @("sdras.vue-vscode-snippets") + @("dariofuzinato.vue-peek") + $AdditionalExtensions
            foreach ($extension in $extensions)
            {
                & $codeCmdPath -ArgumentList --install-extension $extension --force
            }

            Write-Host "`nInstallation complete!`n`n" -ForegroundColor Green
            
        }
        finally
        {
            $ProgressPreference = 'Continue'
        }
    }
    else
    {
        Write-Error "This script is currently only supported on the Windows operating system."
    }
}

if ($AzureCLI.IsPresent -or $All.IsPresent)
{
    Write-Host "Installing Azure CLI"
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
    Remove-Item .\AzureCLI.msi
}

if ($Fork.IsPresent -or $All.IsPresent)
{
    #C:\Users\jbarden\AppData\Local\Fork\Fork.exe
    $appName = "Fork"
    if(!(Test-Path "$env:LOCALAPPDATA\fork\$appName.exe")){
        Write-Host "Downloading $appName"
        Invoke-WebRequest -Uri  https://cdn.fork.dev/win/Fork-1.83.1.exe -OutFile .\$appName.exe
        Write-Host "Installing $appName"
        Start-Process .\$appName.exe -Wait
        Remove-Item .\$appName.exe
        Write-Host "Installed $appName" -ForegroundColor Green
    }
    else{
        Write-Host "$appName is already installed" -ForegroundColor Green
    }
}

if ($CreateDirectories.IsPresent -or $All.IsPresent)
{
    Write-Host "Creating default directories..."
    $DefaultDirectories = @("c:\temp", "c:\GitHub\mine", "c:\GitHub\work", "c:\repos", "c:\repos\mine", "c:\repos\work")
    foreach($directory in $DefaultDirectories){
        if (!(Test-Path $directory)){
            Write-Host "$($directory) does not exist...creating"
            New-Item -Path $directory -ItemType Directory
        }
        else {
            Write-Host "$($directory) exists...moving on" -ForegroundColor Green
        }
    }
    
    Write-Host "Creating additional directories (if specified)..."
    foreach($directory in $Directories){
        if (!(Test-Path $directory)){
            Write-Host "$($directory) does not exist...creating"
            New-Item -Path $directory -ItemType Directory
        }
        else {
            Write-Host "$($directory) exists...moving on" -ForegroundColor Green
        }
    }
    Write-Host "CreateDirectories completed" -ForegroundColor Green
}

if ($RecommendedApplications.IsPresent -or $All.IsPresent) {

    $appName = "GIT"
    if(!(Test-Path "$codePath\Git\bin\$appName.exe")){
        Write-Host "Downloading $appName"
        Invoke-WebRequest -Uri https://github.com/git-for-windows/git/releases/download/v2.39.1.windows.1/Git-2.39.1-64-bit.exe -OutFile .\$appName.exe
        Write-Host "Installing $appName"
        Start-Process .\$appName.exe -Wait
        Remove-Item .\$appName.exe
        Write-Host "Installed $appName" -ForegroundColor Green
    }
    else{
        Write-Host "$appName is already installed" -ForegroundColor Green
    }

    $appName = "GitHub Desktop"
    if(!(Test-Path "$env:USERPROFILE\AppData\Local\GitHubDesktop\GitHubDesktop.exe")){
        Write-Host "Downloading $appName"
        Invoke-WebRequest -Uri https://central.github.com/deployments/desktop/desktop/latest/win32 -OutFile .\$appName.exe
        Write-Host "Installing $appName"
        Start-Process .\$appName.exe -Wait
        Remove-Item .\$appName.exe
        Write-Host "Installed $appName" -ForegroundColor Green
    }
    else{
        Write-Host "$appName is already installed" -ForegroundColor Green
    }

    $appName = "Microsoft.PowerShell"
    if(!(Test-Path "TBC")){
        Write-Host "Installing $appName"
        Install-Module -Name Terminal-Icons -Repository PSGallery
        winget install Microsoft.PowerShell
        Write-Host "Installed $appName" -ForegroundColor Green
        Write-Host "Please remember to set $appName as the default profile in Terminal!!!" -ForegroundColor Green
    }
    else{
        Write-Host "$appName is already installed" -ForegroundColor Green
    }

    $appName = "CascadiaCode"
    if(!(Test-Path "C:\Windows\Fonts\Caskaydia Cove              Nerd Font Complete Windows Compatible.ttf")){
        Write-Host "Downloading $appName"
        Invoke-WebRequest -Uri https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip?WT.mc_id=-blog-scottha -OutFile .\$appName.zip
        Write-Host "Installing $appName"
        Expand-Archive -LiteralPath .\$appName.zip -DestinationPath .\$appName\ -Force
        Remove-Item .\$appName.zip
        Invoke-Item .
        Write-Host "Please install the fonts" -ForegroundColor Green
        # winget install JanDeDobbeleer.OhMyPosh
    }
    else{
        Write-Host "$appName is already installed" -ForegroundColor Green
    }
    
    $appName = "OhMyPosh"
    if(!(Test-Path "TBC")){
        Write-Host "Installing $appName"
        winget install JanDeDobbeleer.OhMyPosh
        Write-Host "Installed $appName" -ForegroundColor Green
        Write-Host "Please remember to set Microsoft.PowerShell as the default profile in Terminal!!!" -ForegroundColor Green

    }
    else{
        Write-Host "$appName is already installed" -ForegroundColor Green
    }
    
    $appName = "PowerShell Profile file"
    if(!(Test-Path $profile)){
        Write-Host "Creating $appName"
        New-Item -path $profile -type file
        Write-Host "Created $appName" -ForegroundColor Green
        Write-Host "Please remember to set Microsoft.PowerShell as the default profile in Terminal!!!" -ForegroundColor Green
    }
    else{
        Write-Host "$appName already exists" -ForegroundColor Green
    }

    if(!(Test-Path "$codePath\Notepad++\notepad++.exe")){
        Write-Host "Downloading Notepad++"
        Invoke-WebRequest -Uri https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4.6/npp.8.4.6.Installer.x64.exe -OutFile .\npp.8.4.6.Installer.x64.exe
        Write-Host "Installing Notepad++"
        Start-Process npp.8.4.6.Installer.x64.exe -Wait
        Remove-Item .\npp.8.4.6.Installer.x64.exe
        Write-Host "Installed Notepad++" -ForegroundColor Green
    }
    else{
        Write-Host "Notepad++ is already installed" -ForegroundColor Green
    }

    if(!(Test-Path "C:\Program Files\Docker\Docker\Docker Desktop.exe")){
        Write-Host "Downloading Docker"
        Invoke-WebRequest -Uri https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe -OutFile .\docker.exe
        Write-Host "Installing Docker"
        Start-Process .\Docker.exe -Wait
        Remove-Item .\Docker.exe
        Write-Host "Installed Docker" -ForegroundColor Green
    }
    else{
        Write-Host "Docker is already installed" -ForegroundColor Green
    }

    if(!(Test-Path "$env:LOCALAPPDATA\Postman\postman.exe")){
        Write-Host "Downloading Postman"
        Invoke-WebRequest -Uri https://dl.pstmn.io/download/latest/win64 -OutFile .\postman.exe
        Write-Host "Installing Postman"
        Start-Process .\postman.exe -Wait
        Remove-Item .\postman.exe
        Write-Host "Installed Postman" -ForegroundColor Green
    }
    else{
        Write-Host "Postman is already installed" -ForegroundColor Green
    }

    if(!(Test-Path "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe")){
        Write-Host "Installing Docker"
        Invoke-WebRequest -Uri https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe -OutFile .\Docker.exe
        Start-Process .\Docker.exe -Wait
        Remove-Item .\Docker.exe
        Write-Host "Installed Docker" -ForegroundColor Green
    }
    else{
        Write-Host "Docker is already installed" -ForegroundColor Green
    }

    if(!(Test-Path "$codePath\WinMerge\WinMergeU.exe")){
        Write-Host "Downloading WinMerge"
        Invoke-WebRequest -Uri https://github.com/WinMerge/winmerge/releases/download/v2.16.22/WinMerge-2.16.22-x64-Setup.exe -OutFile .\WinMerge-2.16.22-x64-Setup.exe
        Write-Host "Installing WinMerge"
        Start-Process WinMerge-2.16.22-x64-Setup.exe -Wait
        Remove-Item .\WinMerge-2.16.22-x64-Setup.exe
        Write-Host "Installed WinMerge" -ForegroundColor Green
    }
    else{
        Write-Host "WinMerge is already installed" -ForegroundColor Green
    }
    
    if(!(Test-Path "$codePath\7-Zip\7z.exe")){
        Write-Host "Downloading 7zip"
        Invoke-WebRequest -Uri https://www.7-zip.org/a/7z2201-x64.exe -OutFile .\7z2201-x64.exe
        Write-Host "Installing 7zip"
        Start-Process 7z2201-x64.exe -Wait
        Remove-Item .\7z2201-x64.exe
        Write-Host "Installed 7zip" -ForegroundColor Green
    }
    else{
        Write-Host "7zip is already installed" -ForegroundColor Green
    }
}

if ($VisualStudio.IsPresent -or $All.IsPresent) 
{
    Write-Host "`nChecking whether Visual Studio is installed..." 
    if (($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows)
    {
        $vsExePath = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
        $appName = "Visual Studio 2022 ($($Architecture))"
        
        try
        {
            $ProgressPreference = 'SilentlyContinue'
            if (!(Test-Path $vsExePath))
            {
                $vsDownloadFileName = "$env:USERPROFILE\downloads\VisualStudio-2022-$($BuildEdition).exe"
                Write-Host "`nDownloading latest $appName to $vsDownloadFileName..." -ForegroundColor Yellow
                Remove-Item -Force $vsDownloadFileName -ErrorAction SilentlyContinue
                Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_$VisualStudioEdition.exe" -OutFile $vsDownloadFileName
                Write-Host "`nInstalling $appName..." -ForegroundColor Yellow
                Start-Process -Wait $vsDownloadFileName -ArgumentList /silent, /mergetasks=!runcode
                Write-Host "`nInstallation complete!`n`n" -ForegroundColor Green
            }
            else
            {
                Write-Host "`n$appName is already installed." -ForegroundColor Yellow
            }
        }
        finally
        {
            $ProgressPreference = 'Continue'
        }
    }
    else
    {
        Write-Error "This script only supports Visual Studio installation on the Windows operating system... Sorry!"
    }
}