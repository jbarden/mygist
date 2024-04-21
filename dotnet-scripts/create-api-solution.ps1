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
    $HealthChecksProjectName = "$($SolutionName).HealthChecks"
    $APIProjectName = "$($SolutionName).API"
    $DomainProjectName = "$($SolutionName).Domain"
    $InfrastructureProjectName = "$($SolutionName).Infrastructure"
    $HealthChecksDirectory = "$($SourceDirectory)\core\$($HealthChecksProjectName)"

    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process {
    try {        
        if($Redeploy) {
            Write-Output "Removing the previous version located at $($BaseSolutionDirectory)." | WriteColour("Magenta")
            remove-item $($BaseSolutionDirectory) -recurse -force
            Write-Output "Removed the previous version located at $($BaseSolutionDirectory)." | WriteColour("Green")
        }

        Write-Output "Starting directory creation." | WriteColour("Magenta")
        mkdir "$($SourceDirectory)"
        mkdir "$($SourceDirectory)\api"
        mkdir "$($SourceDirectory)\core"
        mkdir "$($BaseSolutionDirectory)\tests\unit"
        mkdir "$($BaseSolutionDirectory)\tests\integration"
        mkdir "$($BaseSolutionDirectory)\tests\acceptance"
        Write-Output "Completed directory creation." | WriteColour("Green")
        
        Write-Output "Copying files." | WriteColour("Magenta")
        xcopy .\.editorconfig $BaseSolutionDirectory /Y
        xcopy .\CodeMaid.config $BaseSolutionDirectory /Y
        xcopy .\.git* $BaseSolutionDirectory /Y
        Write-Output "Completed copying files." | WriteColour("Green")
        
        Write-Output "Creating the solution file." | WriteColour("Magenta")
        dotnet new sln --name "$($SolutionName)" --output "$($BaseSolutionDirectory)"
        
        Write-Output "Creating the API project." | WriteColour("Magenta")
        dotnet new webapi --name "$($APIProjectName)" --output "$($SourceDirectory)\api\$($APIProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($SourceDirectory)\api\$($APIProjectName)"
        dotnet add "$($SourceDirectory)\api\$($APIProjectName)\$($APIProjectName).csproj" package --no-restore AStar.ASPNet.Extensions --version "0.2.0"
        dotnet add "$($SourceDirectory)\api\$($APIProjectName)\$($APIProjectName).csproj" package --no-restore AStar.CodeGenerators --version "0.2.0"
        Write-Output "Created the API project." | WriteColour("Green")
        
        Write-Output "Creating the Domain project." | WriteColour("Magenta")
        dotnet new classlib --name "$($DomainProjectName)" --output "$($SourceDirectory)\core\$($DomainProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($SourceDirectory)\core\$($DomainProjectName)"
        dotnet add "$($SourceDirectory)\api\$($APIProjectName)\$($APIProjectName).csproj" reference "$($SourceDirectory)\core\$($DomainProjectName)"
        Write-Output "Created the Domain project." | WriteColour("Green")
        
        Write-Output "Creating the Infrastructure project." | WriteColour("Magenta")
        dotnet new classlib --name "$($InfrastructureProjectName)" --output "$($SourceDirectory)\core\$($InfrastructureProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($SourceDirectory)\core\$($InfrastructureProjectName)"
        dotnet add "$($SourceDirectory)\api\$($APIProjectName)\$($APIProjectName).csproj" reference "$($SourceDirectory)\core\$($InfrastructureProjectName)"
        dotnet add "$($SourceDirectory)\core\$($InfrastructureProjectName)\$($InfrastructureProjectName).csproj" reference "$($SourceDirectory)\core\$($DomainProjectName)"
        Write-Output "Created the Infrastructure project." | WriteColour("Green")
        
        Write-Output "Creating the Health Checks project." | WriteColour("Magenta")
        dotnet new classlib --name "$($HealthChecksProjectName)" --output "$($SourceDirectory)\core\$($HealthChecksProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($SourceDirectory)\core\$($HealthChecksProjectName)"
        dotnet add "$($SourceDirectory)\api\$($APIProjectName)\$($APIProjectName).csproj" reference "$($SourceDirectory)\core\$($HealthChecksProjectName)"
        dotnet add "$($SourceDirectory)\core\$($HealthChecksProjectName)\$($HealthChecksProjectName).csproj" package --no-restore Microsoft.AspNetCore.Http.Abstractions --version "2.1.1"
        dotnet add "$($SourceDirectory)\core\$($HealthChecksProjectName)\$($HealthChecksProjectName).csproj" package --no-restore Microsoft.Extensions.Diagnostics.HealthChecks.Abstractions --version "7.0.5"
        dotnet add "$($SourceDirectory)\core\$($HealthChecksProjectName)\$($HealthChecksProjectName).csproj" package --no-restore Microsoft.Extensions.Features --version "7.0.7"
        Write-Output "Created the Health Checks project." | WriteColour("Green")
        
        Write-Output "Creating the API Unit Tests project." | WriteColour("Magenta")
        dotnet new xunit --name "$($APIProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests\$($APIProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests\$($APIProjectName).Unit.Tests.csproj" reference "$($SourceDirectory)\api\$($APIProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests"
        Write-Output "Created the API Unit Tests project." | WriteColour("Green")
        
        Write-Output "Creating the Domain Unit Tests project." | WriteColour("Magenta")
        dotnet new xunit --name "$($DomainProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests\$($DomainProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests\$($DomainProjectName).Unit.Tests.csproj" reference "$($SourceDirectory)\core\$($DomainProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests"
        Write-Output "Created the Domain Unit Tests project." | WriteColour("Green")
        
        Write-Output "Creating the Infrastructure Unit Tests project." | WriteColour("Magenta")
        dotnet new xunit --name "$($InfrastructureProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests\$($InfrastructureProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests\$($InfrastructureProjectName).Unit.Tests.csproj" reference "$($SourceDirectory)\core\$($InfrastructureProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests"
        Write-Output "Created the Infrastructure Unit Tests project." | WriteColour("Green")
        
        Write-Output "Creating the API Acceptance Tests project." | WriteColour("Magenta")
        dotnet new xunit --name "$($APIProjectName).Acceptance.Tests" --output "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests\$($APIProjectName).Acceptance.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests\$($APIProjectName).Acceptance.Tests.csproj" reference "$($SourceDirectory)\api\$($APIProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests"
        Write-Output "Created the API Acceptance Tests project." | WriteColour("Green")
        
        dotnet new xunit --name "$($APIProjectName).Integration.Tests" --output "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests"
        dotnet add "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests\$($APIProjectName).Integration.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
        dotnet add "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests\$($APIProjectName).Integration.Tests.csproj" reference "$($SourceDirectory)\api\$($APIProjectName)"
        dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests"

        if($UpdateNuget){
            Set-Location "$($BaseSolutionDirectory)"
            
            dotnet restore "$($SolutionFileWithPath)"
            
            Write-Output "Starting project restores." | WriteColour("Magenta")
            $regex = 'PackageReference Include="([^"]*)" Version="([^"]*)"'
            
            ForEach ($file in get-childitem . -recurse | Where-Object { $_.extension -like "*.csproj" }) {
                $packages = Get-Content $file.FullName |
                select-string -pattern $regex -AllMatches | 
                ForEach-Object { $_.Matches } | 
                ForEach-Object { $_.Groups[1].Value.ToString() } | 
                Sort-Object -Unique
                
                ForEach ($package in $packages) {
                    Write-Output "Update project: $($file.FullName), package: $package." | WriteColour("Magenta")
                    $fullName = $file.FullName
                    dotnet add $fullName package $package
                    Write-Output "Updated project: $($file.FullName), package: $package." | WriteColour("Green")
                }
            }
            Set-Location "$($StartingFolder)"
        }
        
        & "$PSScriptRoot\update-healthchecks-project.ps1" -ProjectFolder "$($HealthChecksDirectory)" -SolutionName $($SolutionName)
        & "$PSScriptRoot\update-api-project.ps1" -ProjectFolder $("$($SourceDirectory)\api\$($APIProjectName)")
        & "$PSScriptRoot\set-projects-to-treat-warnings-as-errors.ps1" -RootDirectory $($RootDirectory) -SolutionName $($SolutionName)

        Write-Output "Running code cleanup - started at $(Get-Date)." | WriteColour("Magenta")
        & 'dotnet' 'format' $SolutionFileWithPath
        Write-Output "Completed code cleanup - finished at $(Get-Date)." | WriteColour("Magenta")
    }
    finally {
        Set-Location "$($StartingFolder)"
    }
}

end {
    $endTime = Get-Date
    $duration = New-TimeSpan -Start $startTime -End $endTime
    Write-Output "Start time: $($startTime)." | WriteColour("DarkYellow")
    Write-Output "End time: $($endTime)." | WriteColour("DarkYellow")
    Write-Output "Total processing time: $($duration.TotalMinutes) minutes." | WriteColour("Green")
    if($LaunchOnCompletion) {
        & 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe' $SolutionFileWithPath
    }
}
