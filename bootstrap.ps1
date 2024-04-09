# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine

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

function InstallIfRequired {
    param (
        $appName, $installPath, $uri
    )

    if ((Test-Path $installPath)) {
        Write-Host "$appName is already installed" -ForegroundColor Green
    }
    else {
        Write-Host "Downloading $appName from $uri"
        Invoke-WebRequest -Uri $uri -OutFile .\$appName.exe
        Write-Host "Downloaded $appName"
        Write-Host "Installing $appName"
        Start-Process .\$appName.exe -Wait
        Remove-Item .\$appName.exe
        Write-Host "Installed $appName" -ForegroundColor Green
    }
}

switch ($Architecture) {
    "64-bit" {
        if ((Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture -eq "64-bit") {
            $codePath = $env:ProgramFiles
            $bitVersion = "win32-x64"
        }
        else {
            $codePath = $env:ProgramFiles
            $bitVersion = "win32"
            $Architecture = "32-bit"
        }
        break;
    }
    "32-bit" {
        if ((Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture -eq "32-bit") {
            $codePath = $env:ProgramFiles
            $bitVersion = "win32"
        }
        else {
            $codePath = ${env:ProgramFiles(x86)}
            $bitVersion = "win32"
        }
        break;
    }
}

if ($RecommendedApplications.IsPresent -or $Fork.IsPresent -or $All.IsPresent) {
    $appName = "Fork" 
    $installPath = "$env:LOCALAPPDATA\fork\$appName.exe"
    $uri = "https://cdn.fork.dev/win/Fork-1.89.1.exe"
    
    InstallIfRequired -appName $appName -installPath $installPath -Uri $uri
}

if ($RecommendedApplications.IsPresent -or $All.IsPresent) {
    $appName = "GIT" 
    $installPath = "$codePath\Git\bin\$appName.exe"
    $uri = "https://github.com/git-for-windows/git/releases/download/v2.39.1.windows.1/Git-2.39.1-64-bit.exe"
    
    InstallIfRequired -appName $appName -installPath $installPath -Uri $uri
}

if ($RecommendedApplications.IsPresent -or $All.IsPresent) {
    $appName = "Notepad++" 
    $installPath = "$codePath\Notepad++\notepad++.exe"
    $uri = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5.6/npp.8.5.6.Installer.x64.exe"
    
    InstallIfRequired -appName $appName -installPath $installPath -Uri $uri
}

if ($RecommendedApplications.IsPresent -or $All.IsPresent) {
    $appName = "Docker" 
    $installPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    $uri = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
    
    InstallIfRequired -appName $appName -installPath $installPath -Uri $uri
}

if ($RecommendedApplications.IsPresent -or $All.IsPresent) {
    $appName = "Postman" 
    $installPath = "$env:LOCALAPPDATA\Postman\postman.exe"
    $uri = "https://dl.pstmn.io/download/latest/win64"
    
    InstallIfRequired -appName $appName -installPath $installPath -Uri $uri
}

if ($RecommendedApplications.IsPresent -or $All.IsPresent) {
    $appName = "WinMerge" 
    $installPath = "$codePath\WinMerge\WinMergeU.exe"
    $uri = "https://github.com/WinMerge/winmerge/releases/download/v2.16.22/WinMerge-2.16.22-x64-Setup.exe"
    
    InstallIfRequired -appName $appName -installPath $installPath -Uri $uri
}

if ($RecommendedApplications.IsPresent -or $All.IsPresent) {
    $appName = "7zip" 
    $installPath = "$codePath\7-Zip\7z.exe"
    $uri = "https://www.7-zip.org/a/7z2201-x64.exe"
    
    InstallIfRequired -appName $appName -installPath $installPath -Uri $uri
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

if ($VSCode.IsPresent -or $All.IsPresent) {
    Write-Host "`nChecking whether VS-Code is installed..." 
    if (($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows) {
        switch ($BuildEdition) {
            "Stable" {
                $codeCmdPath = "$codePath\Microsoft VS Code\bin\code.cmd"
                $appName = "Visual Studio Code ($($Architecture))"
                break;
            }
            "Insider" {
                $codeCmdPath = "$codePath\Microsoft VS Code Insiders\bin\code-insiders.cmd"
                $appName = "Visual Studio Code - Insiders Edition ($($Architecture))"
                break;
            }
        }
        
        if (((Get-CimInstance -ClassName Win32_OperatingSystem).Name).Contains("Windows 11")) {
            $codeCmdPath = "C:\Program Files\Microsoft VS Code\bin\code.cmd"
            Write-Host "`nReset codeCmdPath to: $codeCmdPath..." -ForegroundColor Green
        }
        else {
            Write-Host "`nCodeCmdPath is: $codeCmdPath..." -ForegroundColor Red
        }

        try {
            $ProgressPreference = 'SilentlyContinue'
            if (!(Test-Path $codeCmdPath)) {
                Write-Host "`nDownloading latest $appName..." -ForegroundColor Yellow
                Write-Host "`n$env:TEMP\vscode-$($BuildEdition).exe..." -ForegroundColor Yellow
                Remove-Item -Force "$env:TEMP\vscode-$($BuildEdition).exe" -ErrorAction SilentlyContinue
                Invoke-WebRequest -Uri "https://update.code.visualstudio.com/latest/$($bitVersion)/$($BuildEdition)" -OutFile "$env:TEMP\vscode-$($BuildEdition).exe"
    
                Write-Host "`nInstalling $appName..." -ForegroundColor Yellow
                Start-Process -Wait "$env:TEMP\vscode-$($BuildEdition).exe" -ArgumentList /silent, /mergetasks=!runcode
            }
            else {
                Write-Host "`n$appName is already installed." -ForegroundColor Yellow
            }

            $extensions = @("ms-azuretools.vscode-bicep") + @("ms-vscode.powershell") + @("ms-dotnettools.csharp") + @("christian-kohler.npm-intellisense") + @("ms-azuretools.vscode-docker") + @("github.vscode-github-actions") + $AdditionalExtensions
            foreach ($extension in $extensions) {
                & $codeCmdPath -ArgumentList --install-extension $extension --force
            }

            Write-Host "`nInstallation complete!`n`n" -ForegroundColor Green
            
        }
        finally {
            $ProgressPreference = 'Continue'
        }
    }
    else {
        Write-Error "This script is currently only supported on the Windows operating system."
    }
}

if ($AzureCLI.IsPresent -or $All.IsPresent) {
    Write-Host "Installing Azure CLI"
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
    Remove-Item .\AzureCLI.msi
}

if ($CreateDirectories.IsPresent -or $All.IsPresent) {
    Write-Host "Creating default directories..."
    $DefaultDirectories = @("c:\temp", "c:\repos", "c:\repos\mine", "c:\repos\work")
    foreach ($directory in $DefaultDirectories) {
        if (!(Test-Path $directory)) {
            Write-Host "$($directory) does not exist...creating"
            New-Item -Path $directory -ItemType Directory
        }
        else {
            Write-Host "$($directory) exists...moving on" -ForegroundColor Green
        }
    }
    
    Write-Host "Creating additional directories (if specified)..."
    foreach ($directory in $Directories) {
        if (!(Test-Path $directory)) {
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

    $appName = "Microsoft.PowerShell"
    if (!(Test-Path "TBC")) {
        Write-Host "Installing $appName"
        Install-Module -Name Terminal-Icons -Repository PSGallery
        winget install Microsoft.PowerShell
		winget install JanDeDobbeleer.OhMyPosh
        Write-Host "Installed $appName" -ForegroundColor Green
        Write-Host "Please remember to set $appName as the default profile in Terminal!!!" -ForegroundColor Green
    }
    else {
        Write-Host "$appName is already installed" -ForegroundColor Green
    }

    $appName = "CascadiaCode"
    if (!(Test-Path "C:\Windows\Fonts\Caskaydia Cove Nerd Font Book.ttf")) {
        Write-Host "Downloading $appName"
        Invoke-WebRequest -Uri https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip -OutFile .\$appName.zip
        Write-Host "Installing $appName"
        Expand-Archive -LiteralPath .\$appName.zip -DestinationPath .\$appName\ -Force
        Remove-Item .\$appName.zip
        Invoke-Item .
        Write-Host "Please copy the fonts to c:\windows\fonts" -ForegroundColor Green
    }
    else {
        Write-Host "$appName is already installed" -ForegroundColor Green
    }
}

if ($VisualStudio.IsPresent -or $All.IsPresent) {
    Write-Host "`nChecking whether Visual Studio is installed..." 
    if (($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows) {
        $vsExePath = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
        $appName = "Visual Studio 2022 ($($Architecture))"
        
        try {
            $ProgressPreference = 'SilentlyContinue'
            if (!(Test-Path $vsExePath)) {
                $vsDownloadFileName = "$env:USERPROFILE\downloads\VisualStudio-2022-$($BuildEdition).exe"
                Write-Host "`nDownloading latest $appName to $vsDownloadFileName..." -ForegroundColor Yellow
                Remove-Item -Force $vsDownloadFileName -ErrorAction SilentlyContinue
                Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_$VisualStudioEdition.exe" -OutFile $vsDownloadFileName
                Write-Host "`nInstalling $appName..." -ForegroundColor Yellow
                Start-Process -Wait $vsDownloadFileName -ArgumentList /silent, /mergetasks=!runcode
                Write-Host "`nInstallation complete!`n`n" -ForegroundColor Green
            }
            else {
                Write-Host "`n$appName is already installed." -ForegroundColor Yellow
            }
        }
        finally {
            $ProgressPreference = 'Continue'
        }
    }
    else {
        Write-Error "This script only supports Visual Studio installation on the Windows operating system... Sorry!"
    }
}