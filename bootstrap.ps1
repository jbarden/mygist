[CmdletBinding()]
Param
(
    # Will run everything
    [switch]$All,

    # Bootstrap PS Modules
    [switch]$Bootstrap,

    # Bootstrap VSCode
    [switch]$InstallVSCode,

    # Bootstrap Azure CLI
    [switch]$InstallAzureCLI,

    # Create the default directories (if list supplied below, this will also be created)
    [switch]$CreateDirectories,

    # Installs applications like Docker, Notepad++, WinMerge, 7Zip, etc.
    [switch]$InstallRecommendedApplications,

    # Installs the full Visual Studio 2022 Enterprise
    [switch]$InstallVisualStudio,

    # Visual Studio Code installation
    [parameter()]
    [ValidateSet(, "64-bit", "32-bit")]
    [string]$Architecture = "64-bit",

    [parameter()]
    [ValidateSet("stable", "insider")]
    [string]$BuildEdition = "stable",

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

if ($InstallVSCode.IsPresent -or $All.IsPresent) 
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
            $codeCmdPath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
        }
        try
        {
            $ProgressPreference = 'SilentlyContinue'
            if (!(Test-Path $codeCmdPath))
            {
                Write-Host "`nDownloading latest $appName..." -ForegroundColor Yellow
                Remove-Item -Force "$env:TEMP\vscode-$($BuildEdition).exe" -ErrorAction Stop
                Invoke-WebRequest -Uri "https://update.code.visualstudio.com/latest/$($bitVersion)/$($BuildEdition)" -OutFile "$env:TEMP\vscode-$($BuildEdition).exe"
    
                Write-Host "`nInstalling $appName..." -ForegroundColor Yellow
                Start-Process -Wait "$env:TEMP\vscode-$($BuildEdition).exe" -ArgumentList /silent, /mergetasks=!runcode
            }
            else
            {
                Write-Host "`n$appName is already installed." -ForegroundColor Yellow
            }
    
            $extensions = @("ms-azuretools.vscode-bicep") + $AdditionalExtensions
            foreach ($extension in $extensions)
            {
                Write-Host "`nInstalling extension $extension..." -ForegroundColor Yellow
                & $codeCmdPath --install-extension $extension --force
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

if ($InstallAzureCLI.IsPresent -or $All.IsPresent)
{
    Write-Host "Installing Azure CLI"
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
    Remove-Item .\AzureCLI.msi
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

if ($InstallRecommendedApplications.IsPresent -or $All.IsPresent) {
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

    if(!(Test-Path "$env:LOCALAPPDATA\Postman\postman.exe")){
        Write-Host "Installing Postman"
        Invoke-WebRequest -Uri https://dl.pstmn.io/download/latest/win64 -OutFile .\postman.exe
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

if ($InstallVisualStudio.IsPresent -or $All.IsPresent) 
{
    Write-Host "`nChecking whether Visual Studio is installed..." 
    if (($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows)
    {
        $vsExePath = "$codePath\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
        $appName = "Visual Studio 2022 ($($Architecture))"
        
        try
        {
            $ProgressPreference = 'SilentlyContinue'
            if (!(Test-Path $vsExePath))
            {
                Write-Host "`nDownloading latest $appName..." -ForegroundColor Yellow
                Remove-Item -Force "$env:TEMP\VisualStudio-2022-$($BuildEdition).exe" -ErrorAction Stop
                Invoke-WebRequest -Uri "https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Enterprise&channel=Release&version=VS2022&source=VSLandingPage&cid=2030&passive=false" -OutFile "$env:TEMP\VisualStudio-2022-$($BuildEdition).exe"
    
                Write-Host "`nInstalling $appName..." -ForegroundColor Yellow
                Start-Process -Wait "$env:TEMP\VisualStudio-2022-$($BuildEdition).exe" -ArgumentList /silent, /mergetasks=!runcode
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
        Write-Error "This script is currently only supported on the Windows operating system."
    }
}