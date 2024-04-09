#  .\Create-Blazor-Solution.ps1 -RootDirectory c:\repos -SolutionName AStar.ASPNet.Extensions

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage='Specify the root directory to use to create the new solution.')]
    [string]$RootDirectory,
    [Parameter(Mandatory = $true, HelpMessage='Specify the solution name, this will be used to create the solution file and all associated projects.')]
    [string]$SolutionName
)
$StartingFolder = Get-Location
$SolutionFile = "$($SolutionName).sln"
$SolutionNameAsPath = $SolutionName.Replace(".", "-").ToLower()
$BaseSolutionDirectory = "$($RootDirectory)\$($SolutionNameAsPath)"
$SolutionFileWithPath = "$($BaseSolutionDirectory)\$($SolutionFile)"
$UIProjectName = "$($SolutionName).UI"
$APIProjectName = "$($SolutionName).API"
$DomainProjectName = "$($SolutionName).Domain"
$InfrastructureProjectName = "$($SolutionName).Infrastructure"
$startTime = Get-Date

mkdir "$($BaseSolutionDirectory)\src"
mkdir "$($BaseSolutionDirectory)\src\ui"
mkdir "$($BaseSolutionDirectory)\src\api"
mkdir "$($BaseSolutionDirectory)\src\core"
mkdir "$($BaseSolutionDirectory)\tests\unit"
mkdir "$($BaseSolutionDirectory)\tests\integration"
mkdir "$($BaseSolutionDirectory)\tests\acceptance"
mkdir "$($BaseSolutionDirectory)\tests\architecture"

xcopy .\.editorconfig $BaseSolutionDirectory /Y
xcopy .\CodeMaid.config $BaseSolutionDirectory /Y
xcopy .\.git* $BaseSolutionDirectory /Y

dotnet new sln --name "$($SolutionName)" --output "$($BaseSolutionDirectory)"
dotnet new blazor --name "$($UIProjectName)" --output "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"

dotnet new webapi --name "$($APIProjectName)" --output "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"

dotnet new classlib --name "$($DomainProjectName)" --output "$($BaseSolutionDirectory)\src\core\$($DomainProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\src\core\$($DomainProjectName)"
dotnet add "$($BaseSolutionDirectory)\src\api\$($APIProjectName)\$($APIProjectName).csproj" reference "$($BaseSolutionDirectory)\src\core\$($DomainProjectName)"

dotnet new classlib --name "$($InfrastructureProjectName)" --output "$($BaseSolutionDirectory)\src\core\$($InfrastructureProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\src\core\$($InfrastructureProjectName)"
dotnet add "$($BaseSolutionDirectory)\src\api\$($APIProjectName)\$($APIProjectName).csproj" reference "$($BaseSolutionDirectory)\src\core\$($InfrastructureProjectName)"
dotnet add "$($BaseSolutionDirectory)\src\core\$($InfrastructureProjectName)\$($InfrastructureProjectName).csproj" reference "$($BaseSolutionDirectory)\src\core\$($DomainProjectName)"

dotnet new xunit --name "$($UIProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests"
dotnet add "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests\$($UIProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions
dotnet add "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests\$($UIProjectName).Unit.Tests.csproj" reference "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests"

dotnet new xunit --name "$($APIProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests"
dotnet add "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests\$($APIProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions
dotnet add "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests\$($APIProjectName).Unit.Tests.csproj" reference "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests"

dotnet new xunit --name "$($DomainProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests"
dotnet add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests\$($DomainProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions
dotnet add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests\$($DomainProjectName).Unit.Tests.csproj" reference "$($BaseSolutionDirectory)\src\core\$($DomainProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests"

dotnet new xunit --name "$($InfrastructureProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests"
dotnet add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests\$($InfrastructureProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions
dotnet add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests\$($InfrastructureProjectName).Unit.Tests.csproj" reference "$($BaseSolutionDirectory)\src\core\$($InfrastructureProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests"

dotnet new xunit --name "$($UIProjectName).Integration.Tests" --output "$($BaseSolutionDirectory)\tests\integration\$($UIProjectName).Integration.Tests"
dotnet add "$($BaseSolutionDirectory)\tests\integration\$($UIProjectName).Integration.Tests\$($UIProjectName).Integration.Tests.csproj" package --no-restore FluentAssertions
dotnet add "$($BaseSolutionDirectory)\tests\integration\$($UIProjectName).Integration.Tests\$($UIProjectName).Integration.Tests.csproj" reference "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\integration\$($UIProjectName).Integration.Tests"

dotnet new xunit --name "$($UIProjectName).Acceptance.Tests" --output "$($BaseSolutionDirectory)\tests\acceptance\$($UIProjectName).Acceptance.Tests"
dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($UIProjectName).Acceptance.Tests\$($UIProjectName).Acceptance.Tests.csproj" package --no-restore FluentAssertions
dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($UIProjectName).Acceptance.Tests\$($UIProjectName).Acceptance.Tests.csproj" reference "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\acceptance\$($UIProjectName).Acceptance.Tests"

dotnet new xunit --name "$($APIProjectName).Acceptance.Tests" --output "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests"
dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests\$($APIProjectName).Acceptance.Tests.csproj" package --no-restore FluentAssertions
dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests\$($APIProjectName).Acceptance.Tests.csproj" reference "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests"

dotnet new xunit --name "$($APIProjectName).Integration.Tests" --output "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests"
dotnet add "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests\$($APIProjectName).Integration.Tests.csproj" package --no-restore FluentAssertions
dotnet add "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests\$($APIProjectName).Integration.Tests.csproj" reference "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests"

dotnet new xunit --name "$($SolutionName).Architecture.Tests" --output "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests"
dotnet add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests\$($SolutionName).Architecture.Tests.csproj" package --no-restore FluentAssertions
dotnet add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests\$($SolutionName).Architecture.Tests.csproj" reference "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"
dotnet add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests\$($SolutionName).Architecture.Tests.csproj" reference "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
dotnet add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests\$($SolutionName).Architecture.Tests.csproj" reference "$($BaseSolutionDirectory)\src\core\$($DomainProjectName)"
dotnet add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests\$($SolutionName).Architecture.Tests.csproj" reference "$($BaseSolutionDirectory)\src\core\$($InfrastructureProjectName)"
dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests"

Set-Location "$($BaseSolutionDirectory)"

$regex = 'PackageReference Include="([^"]*)" Version="([^"]*)"'

ForEach ($file in get-childitem . -recurse | Where-Object {$_.extension -like "*proj"})
{
    $packages = Get-Content $file.FullName |
        select-string -pattern $regex -AllMatches | 
        ForEach-Object {$_.Matches} | 
        ForEach-Object {$_.Groups[1].Value.ToString()}| 
        Sort-Object -Unique
    
    ForEach ($package in $packages)
    {
        Write-Output "Update $file package :$package"  -foreground 'magenta'
        $fullName = $file.FullName
        Invoke-Expression "dotnet add $fullName package $package"
    }
}

Set-Location "$($StartingFolder)"

$endTime = Get-Date
$duration = New-TimeSpan -Start $startTime -End $endTime
Write-Output "Total processing time: $($duration.TotalMinutes) minutes"
