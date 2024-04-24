function CreateBlazorUi {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$BaseSolutionDirectory,
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$SolutionName,
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$SolutionFileWithPath
    )
    
    $UIProjectName = "$($SolutionName).UI"
    $UIDirectory = "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"    
    
    WriteColour -Message "Creating the UI project." -Colour "Magenta"
    dotnet new blazor --name "$($UIProjectName)" --output "$($UIDirectory)"
    dotnet sln "$($SolutionFileWithPath)" add "$($UIDirectory)"
    dotnet add "$($UIDirectory)\$($UIProjectName).csproj" package --no-restore Blazor.Bootstrap --version "2.2.0"
    dotnet add "$($UIDirectory)\$($UIProjectName).csproj" package --no-restore AStar.ASPNet.Extensions --version "0.3.1"
    dotnet add "$($UIDirectory)\$($UIProjectName).csproj" package --no-restore AStar.CodeGenerators --version "0.2.0"
    dotnet add "$($UIDirectory)\$($UIProjectName).csproj" package --no-restore AStar.Logging.Extensions --version "0.1.0"
    WriteColour -Message "Created the UI project." -Colour "Green"
}

Export-ModuleMember -Function CreateBlazorUi