function CreateDirectories {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$BaseSolutionDirectory,
        [Parameter(Mandatory = $false, HelpMessage = 'Specify the solution name, this will be used to create the solution file and all associated projects.')]
        [bool]$CreateUiDirectories = $false
    )

    WriteColour -Message "Starting directory creation." -Colour "Magenta"
    mkdir "$($BaseSolutionDirectory)\src"
    mkdir "$($BaseSolutionDirectory)\src\api"
    mkdir "$($BaseSolutionDirectory)\src\core"
    mkdir "$($BaseSolutionDirectory)\tests\unit"
    mkdir "$($BaseSolutionDirectory)\tests\integration"
    mkdir "$($BaseSolutionDirectory)\tests\acceptance"
    WriteColour -Message "Completed directory creation." -Colour "Green"
    
    if($CreateUiDirectories) {
        mkdir "$($BaseSolutionDirectory)\src\ui"
    }
}

Export-ModuleMember -Function CreateDirectories