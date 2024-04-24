#  .\Create-Blazor-Solution.ps1 -RootDirectory c:\repos -SolutionName AStar.ASPNet.Extensions

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$RootDirectory,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the solution name, this will be used to create the solution file and all associated projects.')]
    [string]$SolutionName,
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
    $APIProjectName = "$($SolutionName).API"
    $DomainProjectName = "$($SolutionName).Domain"
    $InfrastructureProjectName = "$($SolutionName).Infrastructure"

    $userHome = $env:USERPROFILE
    xcopy .\helper-scripts\Modules\ $userHome\OneDrive\Documents\PowerShell\Modules\ /Y /S
    Import-Module WriteColour -Force
    Import-Module CreateDirectories -Force
    Import-Module CopySolutionFiles -Force
    Import-Module RemovePreviousSolution -Force
    Import-Module CreateApi -Force
    Import-Module UpdateNuget -Force
}

process {
    try {
        if($Redeploy) {
            RemovePreviousSolution -BaseSolutionDirectory $BaseSolutionDirectory
        }

        CreateDirectories -BaseSolutionDirectory $BaseSolutionDirectory -CreateUiDirectories $false
        CopySolutionFiles -BaseSolutionDirectory $BaseSolutionDirectory -APIProjectName $APIProjectName -SolutionName $SolutionName
        
        WriteColour -Message "Creating the solution file." -Colour "Magenta"
        dotnet new sln --name "$($SolutionName)" --output "$($BaseSolutionDirectory)"

        CreateApi -BaseSolutionDirectory $BaseSolutionDirectory -APIProjectName $APIProjectName -SolutionFileWithPath $SolutionFileWithPath
        
        WriteColour -Message "Creating the Domain project." -Colour "Magenta"
        dotnet new classlib --name "$($DomainProjectName)" --output "$($SourceDirectory)\core\$($DomainProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($SourceDirectory)\core\$($DomainProjectName)"
        dotnet add "$($SourceDirectory)\api\$($APIProjectName)\$($APIProjectName).csproj" reference "$($SourceDirectory)\core\$($DomainProjectName)"
        WriteColour -Message "Created the Domain project." -Colour "Green"
        
        WriteColour -Message "Creating the Infrastructure project." -Colour "Magenta"
        dotnet new classlib --name "$($InfrastructureProjectName)" --output "$($SourceDirectory)\core\$($InfrastructureProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($SourceDirectory)\core\$($InfrastructureProjectName)"
        dotnet add "$($SourceDirectory)\api\$($APIProjectName)\$($APIProjectName).csproj" reference "$($SourceDirectory)\core\$($InfrastructureProjectName)"
        dotnet add "$($SourceDirectory)\core\$($InfrastructureProjectName)\$($InfrastructureProjectName).csproj" reference "$($SourceDirectory)\core\$($DomainProjectName)"
        WriteColour -Message "Created the Infrastructure project." -Colour "Green"
        
        WriteColour -Message "Creating the API Unit Tests project." -Colour "Magenta"
        dotnet new xunit --name "$($APIProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests"
        UpdateNuget -BaseSolutionDirectory "$($BaseSolutionDirectory)"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests\$($APIProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests\$($APIProjectName).Unit.Tests.csproj" reference "$($SourceDirectory)\api\$($APIProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests"
        WriteColour -Message "Created the API Unit Tests project." -Colour "Green"
        
        WriteColour -Message "Creating the Domain Unit Tests project." -Colour "Magenta"
        dotnet new xunit --name "$($DomainProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests"
        UpdateNuget -BaseSolutionDirectory "$($BaseSolutionDirectory)"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests\$($DomainProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests\$($DomainProjectName).Unit.Tests.csproj" reference "$($SourceDirectory)\core\$($DomainProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests"
        WriteColour -Message "Created the Domain Unit Tests project." -Colour "Green"
        
        WriteColour -Message "Creating the Infrastructure Unit Tests project." -Colour "Magenta"
        dotnet new xunit --name "$($InfrastructureProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests"
        UpdateNuget -BaseSolutionDirectory "$($BaseSolutionDirectory)"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests\$($InfrastructureProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests\$($InfrastructureProjectName).Unit.Tests.csproj" reference "$($SourceDirectory)\core\$($InfrastructureProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests"
        WriteColour -Message "Created the Infrastructure Unit Tests project." -Colour "Green"
        
        WriteColour -Message "Creating the API Acceptance Tests project." -Colour "Magenta"
        dotnet new xunit --name "$($APIProjectName).Acceptance.Tests" --output "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests"
        UpdateNuget -BaseSolutionDirectory "$($BaseSolutionDirectory)"
        dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests\$($APIProjectName).Acceptance.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests\$($APIProjectName).Acceptance.Tests.csproj" reference "$($SourceDirectory)\api\$($APIProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests"
        WriteColour -Message "Created the API Acceptance Tests project." -Colour "Green"
        
        dotnet new xunit --name "$($APIProjectName).Integration.Tests" --output "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests\$($APIProjectName).Integration.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests\$($APIProjectName).Integration.Tests.csproj" reference "$($SourceDirectory)\api\$($APIProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests"
        
        remove-item '$($BaseSolutionDirectory)\Class1.cs' -recurse -force

        if($UpdateNuget){
            Set-Location "$($BaseSolutionDirectory)"
            UpdateNuget -BaseSolutionDirectory "$($BaseSolutionDirectory)"
            Set-Location "$($StartingFolder)"
        }
        
        & "$PSScriptRoot\update-api-project.ps1" -ProjectFolder $("$($SourceDirectory)\api\$($APIProjectName)") -APIProjectName $APIProjectName
        & "$PSScriptRoot\set-projects-to-treat-warnings-as-errors.ps1" -RootDirectory $($RootDirectory) -SolutionName $($SolutionName)

        WriteColour -Message "Running code cleanup - started at $(Get-Date)." -Colour "Magenta"
        & 'dotnet' 'format' $SolutionFileWithPath
        WriteColour -Message "Completed code cleanup - finished at $(Get-Date)." -Colour "Magenta"
    }
    finally {
        Set-Location "$($StartingFolder)"
    }
}

end {
    $endTime = Get-Date
    $duration = New-TimeSpan -Start $startTime -End $endTime
    WriteColour -Message "Start time: $($startTime)." -Colour "DarkYellow"
    WriteColour -Message "End time: $($endTime)." -Colour "DarkYellow"
    WriteColour -Message "Total processing time: $($duration.TotalMinutes) minutes." -Colour "Green"
    if($LaunchOnCompletion) {
        & 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe' $SolutionFileWithPath
    }
}
