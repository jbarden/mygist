#  .\Create-Blazor-Solution.ps1 -RootDirectory c:\repos -SolutionName AStar.ASPNet.Extensions

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$RootDirectory,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the solution name, this will be used to create the solution file and all associated projects.')]
    [string]$SolutionName,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the description for the repository.')]
    [string]$Description,
    [Parameter(HelpMessage='Specifies whether the GIT repo should be initialised. The default is true.')]
    [bool]$CreateAndConfigureGitHubRepo = $true,
    [Parameter(Mandatory = $false, HelpMessage = 'Specify the bearer token to access GitHub with.')]
    [string]$BearerToken,
    [Parameter(Mandatory = $false, HelpMessage = 'Specify the owner / organisation for the repository.')]
    [string]$Owner = "astar-development",
    [Parameter(HelpMessage='Controls whether to run the update and NuGet restore. The default is $true to update all NuGet packages but this does add roughly 2 minutes.')]
    [bool]$UpdateNuget = $true,
    [Parameter(HelpMessage='Controls whether to redploy (i.e. remove all existing files) the template. The default is, for safety, $false.')]
    [bool]$Redeploy = $false,
    [Parameter(HelpMessage='Controls whether to launch the new solution. The default is, for the sake of speed, $false.')]
    [bool]$LaunchOnCompletion = $false
)

begin {
    $startTime = Get-Date
    $StartingFolder = Get-Location
    $SolutionFile = "$($SolutionName).sln"
    $SolutionNameAsPath = $SolutionName.Replace(".", "-").ToLower()
    $BaseSolutionDirectory = "$($RootDirectory)\$($SolutionNameAsPath)"
    $SourceDirectory = "$($BaseSolutionDirectory)\src"
    $SolutionFileWithPath = "$($BaseSolutionDirectory)\$($SolutionFile)"
    $UIProjectName = "$($SolutionName).UI"
    $ProjectName = "$($SolutionName).API"
    $DomainProjectName = "$($SolutionName).Domain"
    $InfrastructureProjectName = "$($SolutionName).Infrastructure"
    $UIDirectory = "$($SourceDirectory)\ui\$($UIProjectName)"

    $userHome = $env:USERPROFILE
    xcopy .\helper-scripts\Modules\ $userHome\OneDrive\Documents\PowerShell\Modules\ /Y /S
    Import-Module WriteColour
    Import-Module CreateInitialSolution
    Import-Module RemovePreviousSolution
    Import-Module CreateBlazorUi
    Import-Module CreateApi
    Import-Module WarningsAsErrors -Force
    Import-Module -Name EndOutput -Force
    Import-Module -Name GitHubPipelines -Force
    Import-Module -Name CommitInitialSolution -Force
}

process {
    try { 
        if($Redeploy) {
            RemovePreviousSolution -BaseSolutionDirectory $BaseSolutionDirectory
        }
        
        CreateInitialSolution -BaseSolutionDirectory $BaseSolutionDirectory -ProjectName $ProjectName -SolutionName $SolutionName -CreateUiDirectories $true -CreateAndConfigureGitHubRepo $CreateAndConfigureGitHubRepo -CreateClassLibrary $false -BearerToken $BearerToken -Owner $Owner -StartingFolder $StartingFolder -Description $Description

        WriteColour -Message "Creating the solution file." -Colour "Magenta"
        dotnet new sln --name "$($SolutionName)" --output "$($BaseSolutionDirectory)"

        CreateBlazorUi -BaseSolutionDirectory $BaseSolutionDirectory -SolutionName $SolutionName -SolutionFileWithPath $SolutionFileWithPath
        
        WriteColour -Message "Creating the API project." -Colour "Magenta"
        dotnet new webapi --name "$($ProjectName)" --output "$($SourceDirectory)\api\$($ProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($SourceDirectory)\api\$($ProjectName)"
        dotnet add "$($SourceDirectory)\api\$($ProjectName)\$($ProjectName).csproj" package --no-restore AStar.ASPNet.Extensions --version "0.3.1"
        dotnet add "$($SourceDirectory)\api\$($ProjectName)\$($ProjectName).csproj" package --no-restore AStar.CodeGenerators --version "0.2.0"
        dotnet add "$($SourceDirectory)\api\$($ProjectName)\$($ProjectName).csproj" package --no-restore AStar.Api.HealthChecks --version "0.1.0-alpha"
        dotnet add "$($SourceDirectory)\api\$($ProjectName)\$($ProjectName).csproj" package --no-restore AStar.Logging.Extensions --version "0.1.0"
        WriteColour -Message "Created the API project." -Colour "Green"
        
        WriteColour -Message "Creating the Domain project." -Colour "Magenta"
        dotnet new classlib --name "$($DomainProjectName)" --output "$($SourceDirectory)\core\$($DomainProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($SourceDirectory)\core\$($DomainProjectName)"
        dotnet add "$($SourceDirectory)\api\$($ProjectName)\$($ProjectName).csproj" reference "$($SourceDirectory)\core\$($DomainProjectName)"
        WriteColour -Message "Created the Domain project." -Colour "Green"
        
        WriteColour -Message "Creating the Infrastructure project." -Colour "Magenta"
        dotnet new classlib --name "$($InfrastructureProjectName)" --output "$($SourceDirectory)\core\$($InfrastructureProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($SourceDirectory)\core\$($InfrastructureProjectName)"
        dotnet add "$($SourceDirectory)\api\$($ProjectName)\$($ProjectName).csproj" reference "$($SourceDirectory)\core\$($InfrastructureProjectName)"
        dotnet add "$($SourceDirectory)\core\$($InfrastructureProjectName)\$($InfrastructureProjectName).csproj" reference "$($SourceDirectory)\core\$($DomainProjectName)"
        WriteColour -Message "Created the Infrastructure project." -Colour "Green"
        
        WriteColour -Message "Creating the UI Unit Tests project." -Colour "Magenta"
        dotnet new xunit --name "$($UIProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests\$($UIProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests\$($UIProjectName).Unit.Tests.csproj" reference "$($UIDirectory)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests"
        WriteColour -Message "Created the UI Unit Tests project." -Colour "Green"
        
        WriteColour -Message "Creating the API Unit Tests project." -Colour "Magenta"
        dotnet new xunit --name "$($ProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($ProjectName).Unit.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($ProjectName).Unit.Tests\$($ProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($ProjectName).Unit.Tests\$($ProjectName).Unit.Tests.csproj" reference "$($SourceDirectory)\api\$($ProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($ProjectName).Unit.Tests"
        WriteColour -Message "Created the API Unit Tests project." -Colour "Green"
        
        WriteColour -Message "Creating the Domain Unit Tests project." -Colour "Magenta"
        dotnet new xunit --name "$($DomainProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests\$($DomainProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests\$($DomainProjectName).Unit.Tests.csproj" reference "$($SourceDirectory)\core\$($DomainProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests"
        WriteColour -Message "Created the Domain Unit Tests project." -Colour "Green"
        
        WriteColour -Message "Creating the Infrastructure Unit Tests project." -Colour "Magenta"
        dotnet new xunit --name "$($InfrastructureProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests\$($InfrastructureProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests\$($InfrastructureProjectName).Unit.Tests.csproj" reference "$($SourceDirectory)\core\$($InfrastructureProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests"
        WriteColour -Message "Created the Infrastructure Unit Tests project." -Colour "Green"
        
        WriteColour -Message "Creating the UI Integration Tests project." -Colour "Magenta"
        dotnet new xunit --name "$($UIProjectName).Integration.Tests" --output "$($BaseSolutionDirectory)\tests\integration\$($UIProjectName).Integration.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\integration\$($UIProjectName).Integration.Tests\$($UIProjectName).Integration.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\integration\$($UIProjectName).Integration.Tests\$($UIProjectName).Integration.Tests.csproj" reference "$($UIDirectory)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\integration\$($UIProjectName).Integration.Tests"
        WriteColour -Message "Created the UI Integration Tests project." -Colour "Green"
        
        WriteColour -Message "Creating the UI Acceptance Tests project." -Colour "Magenta"
        dotnet new xunit --name "$($UIProjectName).Acceptance.Tests" --output "$($BaseSolutionDirectory)\tests\acceptance\$($UIProjectName).Acceptance.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($UIProjectName).Acceptance.Tests\$($UIProjectName).Acceptance.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($UIProjectName).Acceptance.Tests\$($UIProjectName).Acceptance.Tests.csproj" reference "$($UIDirectory)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\acceptance\$($UIProjectName).Acceptance.Tests"
        WriteColour -Message "Created the UI Acceptance Tests project." -Colour "Green"
        
        WriteColour -Message "Creating the API Acceptance Tests project." -Colour "Magenta"
        dotnet new xunit --name "$($ProjectName).Acceptance.Tests" --output "$($BaseSolutionDirectory)\tests\acceptance\$($ProjectName).Acceptance.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($ProjectName).Acceptance.Tests\$($ProjectName).Acceptance.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($ProjectName).Acceptance.Tests\$($ProjectName).Acceptance.Tests.csproj" reference "$($SourceDirectory)\api\$($ProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\acceptance\$($ProjectName).Acceptance.Tests"
        WriteColour -Message "Created the API Acceptance Tests project." -Colour "Green"
        
        dotnet new xunit --name "$($ProjectName).Integration.Tests" --output "$($BaseSolutionDirectory)\tests\integration\$($ProjectName).Integration.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\integration\$($ProjectName).Integration.Tests\$($ProjectName).Integration.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\integration\$($ProjectName).Integration.Tests\$($ProjectName).Integration.Tests.csproj" reference "$($SourceDirectory)\api\$($ProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\integration\$($ProjectName).Integration.Tests"

        if($UpdateNuget){
            Set-Location "$($BaseSolutionDirectory)"
            
            dotnet restore "$($SolutionFileWithPath)"
            
            WriteColour -Message "Starting project restores." -Colour "Magenta"
            $regex = 'PackageReference Include="([^"]*)" Version="([^"]*)"'
            
            ForEach ($file in get-childitem . -recurse | Where-Object { $_.extension -like "*.csproj" }) {
                $packages = Get-Content $file.FullName |
                select-string -pattern $regex -AllMatches | 
                ForEach-Object { $_.Matches } | 
                ForEach-Object { $_.Groups[1].Value.ToString() } | 
                Sort-Object -Unique
                
                ForEach ($package in $packages) {
                    WriteColour -Message "Update project: $($file.FullName), package: $package." -Colour "Magenta"
                    $fullName = $file.FullName
                    dotnet add $fullName package $package
                    WriteColour -Message "Updated project: $($file.FullName), package: $package." -Colour "Green"
                }
            }
            Set-Location "$($StartingFolder)"
        }
        
        & "$PSScriptRoot\update-ui-project.ps1" -ProjectFolder "$($UIDirectory)"
        & "$PSScriptRoot\update-api-project.ps1" -ProjectFolder $("$($SourceDirectory)\api\$($ProjectName)")
        WarningsAsErrors -BaseSolutionDirectory $BaseSolutionDirectory -StartingFolder $StartingFolder

        WriteColour -Message "Running code cleanup - started at $(Get-Date)." -Colour "Magenta"
        & 'dotnet' 'format' $SolutionFileWithPath
        WriteColour -Message "Completed code cleanup - finished at $(Get-Date)." -Colour "Magenta"
        remove-item * -Include Class1.cs -recurse -force

        xcopy $StartingFolder\..\nuget-pipelines\ui\.github $BaseSolutionDirectory\.github\ /Y /S
        GitHubPipelines -BaseSolutionDirectory $BaseSolutionDirectory -SolutionNameAsPath $SolutionNameAsPath -SolutionName $SolutionName

        
        CommitInitialSolution -BaseSolutionDirectory $BaseSolutionDirectory -SolutionNameAsPath $SolutionNameAsPath -BearerToken $BearerToken -SolutionName $SolutionName -Owner $Owner
    }
    finally {
        Set-Location "$($StartingFolder)"
    }
}

end {
    EndOutput -startTime "$($startTime)"
    if($LaunchOnCompletion) {
        & 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe' $SolutionFileWithPath
    }
}
