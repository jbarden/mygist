function CreateApi {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$BaseSolutionDirectory,
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$APIProjectName,
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$SolutionFileWithPath
    )

    $APIDirectory = "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"

    WriteColour -Message "Creating the API project." -Colour "Magenta"
    dotnet new webapi --name "$($APIProjectName)" --output "$($APIDirectory)"

    UpdateNuget -BaseSolutionDirectory "$($BaseSolutionDirectory)"

    dotnet sln "$($SolutionFileWithPath)" add "$($APIDirectory)"
    
    xcopy .\nuget.config "$($APIDirectory)" /Y

    dotnet add "$($APIDirectory)\$($APIProjectName).csproj" package --no-restore AStar.ASPNet.Extensions --version "0.3.1"
    dotnet add "$($APIDirectory)\$($APIProjectName).csproj" package --no-restore AStar.CodeGenerators --version "0.2.0"
    
    WriteColour -Message "Created the API project." -Colour "Green"
}

Export-ModuleMember -Function CreateApi