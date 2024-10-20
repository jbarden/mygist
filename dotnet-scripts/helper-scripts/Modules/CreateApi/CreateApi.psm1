function CreateApi {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the root directory to use to create the new solution.')]
        [string]$BaseSolutionDirectory,
        [Parameter(Mandatory = $true, HelpMessage = 'The project name within the new solution.')]
        [string]$ProjectName,
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the Solution File name with the path.')]
        [string]$SolutionFileWithPath
    )

    Import-Module -Name WriteColour -Force
    $APIDirectory = "$($BaseSolutionDirectory)\src\api\$($ProjectName)"

    WriteColour -Message "Creating the API project." -Colour "Magenta"
    dotnet new webapi --name "$($ProjectName)" --output "$($APIDirectory)"

    UpdateNuget -BaseSolutionDirectory "$($BaseSolutionDirectory)"

    dotnet sln "$($SolutionFileWithPath)" add "$($APIDirectory)"
    
    xcopy .\nuget\nuget.config "$($APIDirectory)" /Y

    dotnet add "$($APIDirectory)\$($ProjectName).csproj" package --no-restore AStar.ASPNet.Extensions --version "0.3.1"
    dotnet add "$($APIDirectory)\$($ProjectName).csproj" package --no-restore AStar.CodeGenerators --version "0.2.0"
    
    WriteColour -Message "Created the API project." -Colour "Green"
}

Export-ModuleMember -Function CreateApi