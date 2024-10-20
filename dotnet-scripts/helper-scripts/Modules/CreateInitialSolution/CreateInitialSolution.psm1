function CreateInitialSolution {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the base solution directory to use to create the new solution.')]
        [string]$BaseSolutionDirectory,
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the Project name to use to create the new solution.')]
        [string]$ProjectName,
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the solution name to use to create the new solution.')]
        [string]$SolutionName,
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the description for the repository.')]
        [string]$Description,
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the Starting Folder to reset the directories so the copy files still work.')]
        [string]$StartingFolder,
        [Parameter(HelpMessage = 'Specifies whether the GIT repo should be initialised. The default is true.')]
        [bool]$CreateAndConfigureGitHubRepo = $true,
        [Parameter(HelpMessage = 'Specifies the Bearer Token to use when configuring the GitHub repo.')]
        [string]$BearerToken,
        [Parameter(Mandatory = $false, HelpMessage = 'Please specify the owner / organisation for the repository.')]
        [string]$Owner = "astar-development",
        [Parameter(Mandatory = $false, HelpMessage = 'Please specify whether the solution being created is a UI solution or not. The default is false.')]
        [bool]$CreateUiDirectories = $false,
        [Parameter(Mandatory = $false, HelpMessage = 'Please specify whether the solution being created is a Class Library or not. The default is false.')]
        [bool]$CreateClassLibrary = $false
    )

    Import-Module CopySolutionFiles
    Import-Module CreateAndConfigureGitHubRepo -Force
    Import-Module -Name WriteColour -Force

    WriteColour -Message "Starting directory creation at $($BaseSolutionDirectory)." -Colour "Magenta"
    mkdir $BaseSolutionDirectory
    if($CreateAndConfigureGitHubRepo) {
        WriteColour -Message "Creating and configuring the GitHub Repo and cloning to the directory: $($BaseSolutionDirectory)." -Colour "Magenta"
        Set-Location $BaseSolutionDirectory
        CreateAndConfigureGitHubRepo -BearerToken $BearerToken -Owner $Owner -RepositoryName $ProjectName -clone $true -RootDirectory $BaseSolutionDirectory -Description $Description
        Set-Location $StartingFolder
    }

    WriteColour -Message "Starting directory creation at $($BaseSolutionDirectory)." -Colour "Magenta"
    mkdir "$($BaseSolutionDirectory)\src"
    WriteColour -Message "Starting directory creation for $($BaseSolutionDirectory)\src\$($SolutionName)." -Colour "Magenta"
    mkdir "$($BaseSolutionDirectory)\src\$($SolutionName)"

    if(!$CreateClassLibrary) {
        mkdir "$($BaseSolutionDirectory)\src\api"
        mkdir "$($BaseSolutionDirectory)\src\core"
        mkdir "$($BaseSolutionDirectory)\tests\integration"
        mkdir "$($BaseSolutionDirectory)\tests\acceptance"
    }

    if($CreateUiDirectories) {
        mkdir "$($BaseSolutionDirectory)\src\ui"
    }

    mkdir "$($BaseSolutionDirectory)\tests\unit"
    WriteColour -Message "Completed directory creation at $($BaseSolutionDirectory)." -Colour "Green"

    dotnet new sln --name "$($SolutionName)" --output $BaseSolutionDirectory

    WriteColour -Message "Starting Unit.Tests creation at $($BaseSolutionDirectory)." -Colour "Magenta"
    dotnet new xunit --name "$($SolutionName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($SolutionName).Unit.Tests"
    dotnet add "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests\$($UIProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"

    $fileContent = Get-Content -Path "$($BaseSolutionDirectory)\tests\unit\$($SolutionName).Unit.Tests\$($SolutionName).Unit.Tests.csproj" -Raw
    $textToReplace = '<Using Include="Xunit" />'
    $fileContent = $fileContent.Replace($textToReplace, '<Using Include="FluentAssertions" />' + $textToReplace)
    $fileContent | Set-Content -Path "$($BaseSolutionDirectory)\tests\unit\$($SolutionName).Unit.Tests"
    
    dotnet sln "$($BaseSolutionDirectory)\$($SolutionFile)" add "$($BaseSolutionDirectory)\tests\unit\$($SolutionName).Unit.Tests"
    WriteColour -Message "Created Unit.Tests project in $($BaseSolutionDirectory)." -Colour "Magenta"
    
    CopySolutionFiles -BaseSolutionDirectory $BaseSolutionDirectory -ProjectName $ProjectName -SolutionName $SolutionName
}

Export-ModuleMember -Function CreateInitialSolution