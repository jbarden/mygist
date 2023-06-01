# mygist

# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

Setup new PC / Update existing PC

## How to use

The bootstrap.ps1 has several parameters. These include:

- -All - as you can guess, this will run all of the installations / creations
- -Bootstrap - this will install the PowerShell modules listed in the [requirements.psd1](./requirements.psd1) file
- -InstallVSCode - Installs VS Code
- -InstallAzureCLI - Installs the Azure CLI
- -CreateDirectories - Creates the default directories and, if supplied in the -Directories parameter, and additional directories
- -InstallRecommendedApplications - Installs recommended applications such as Notepad++, WinMerge and 7Zip
- -InstallVisualStudio - Installs Visual Studio 2022 Enterprise edition
- -Architecture - an optional parameter to assist in the *which architecture* checks
- -BuildEdition - only relevant to VS Code - can be either *stable* or *insider*
- -AdditionalExtensions - only relevant to VS Code - if populated, the list of extensions will be installed along with VS Code
- -Directories - an optional list of additional directories to create

## Misc
If, as it often does, VS decides to loose the NuGet feed: ```https://api.nuget.org/v3/index.json```

## Example calls

``` PowerShell
.\bootstrap.ps1 -Bootstrap -InstallVsCode -InstallAzureCLI
```

``` PowerShell
.\bootstrap.ps1 -All
```
