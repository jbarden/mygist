#  .\Create-Class-Library-Solution.ps1 -RootDirectory c:\repos -SolutionName AStar.ASPNet.Extensions

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage='Specify the root directory to use to create the new solution.')]
    [string]$RootDirectory,
    [Parameter(Mandatory = $true, HelpMessage='Specify the solution name, this will be used to create the solution file and all associated projects.')]
    [string]$SolutionName
)
$SolutionFile = "$($SolutionName).sln"
$SolutionNameAsPath = $SolutionName.Replace(".", "-").ToLower()

mkdir "$($RootDirectory)\$($SolutionNameAsPath)\src"
mkdir "$($RootDirectory)\$($SolutionNameAsPath)\tests\unit"
mkdir "$($RootDirectory)\$($SolutionNameAsPath)\tests\integration"
mkdir "$($RootDirectory)\$($SolutionNameAsPath)\tests\acceptance"
mkdir "$($RootDirectory)\$($SolutionNameAsPath)\tests\architecture"

dotnet new sln --name "$($SolutionName)" --output "$($RootDirectory)\$($SolutionNameAsPath)"
dotnet new classlib --name "$($SolutionName)" --output "$($RootDirectory)\$($SolutionNameAsPath)\src\$SolutionName"
dotnet sln "$($RootDirectory)\$($SolutionNameAsPath)\$SolutionFile" add "$($RootDirectory)\$($SolutionNameAsPath)\src\$SolutionName"

dotnet new xunit --name "$($SolutionName).Unit.Tests" --output "$($RootDirectory)\$($SolutionNameAsPath)\tests\unit\$($SolutionName).Unit.Tests"
dotnet add "$($RootDirectory)\$($SolutionNameAsPath)\tests\unit\$($SolutionName).Unit.Tests\$($SolutionName).Unit.Tests.csproj" reference "$($RootDirectory)\$($SolutionNameAsPath)\src\$($SolutionName)"
dotnet sln "$($RootDirectory)\$($SolutionNameAsPath)\$SolutionFile" add "$($RootDirectory)\$($SolutionNameAsPath)\tests\unit\$($SolutionName).Unit.Tests"

dotnet new xunit --name "$($SolutionName).Integration.Tests" --output "$($RootDirectory)\$($SolutionNameAsPath)\tests\integration\$($SolutionName).Integration.Tests"
dotnet add "$($RootDirectory)\$($SolutionNameAsPath)\tests\integration\$($SolutionName).Integration.Tests\$($SolutionName).Integration.Tests.csproj" reference "$($RootDirectory)\$($SolutionNameAsPath)\src\$($SolutionName)"
dotnet sln "$($RootDirectory)\$($SolutionNameAsPath)\$SolutionFile" add "$($RootDirectory)\$($SolutionNameAsPath)\tests\integration\$($SolutionName).Integration.Tests"

dotnet new xunit --name "$($SolutionName).Acceptance.Tests" --output "$($RootDirectory)\$($SolutionNameAsPath)\tests\acceptance\$($SolutionName).Acceptance.Tests"
dotnet add "$($RootDirectory)\$($SolutionNameAsPath)\tests\acceptance\$($SolutionName).Acceptance.Tests\$($SolutionName).Acceptance.Tests.csproj" reference "$($RootDirectory)\$($SolutionNameAsPath)\src\$($SolutionName)"
dotnet sln "$($RootDirectory)\$($SolutionNameAsPath)\$SolutionFile" add "$($RootDirectory)\$($SolutionNameAsPath)\tests\acceptance\$($SolutionName).Acceptance.Tests"

dotnet new xunit --name "$($SolutionName).Architecture.Tests" --output "$($RootDirectory)\$($SolutionNameAsPath)\tests\architecture\$($SolutionName).Architecture.Tests"
dotnet add "$($RootDirectory)\$($SolutionNameAsPath)\tests\architecture\$($SolutionName).Architecture.Tests\$($SolutionName).Architecture.Tests.csproj" reference "$($RootDirectory)\$($SolutionNameAsPath)\src\$($SolutionName)"
dotnet sln "$($RootDirectory)\$($SolutionNameAsPath)\$SolutionFile" add "$($RootDirectory)\$($SolutionNameAsPath)\tests\architecture\$($SolutionName).Architecture.Tests"

Set-Location "$($RootDirectory)\$($SolutionNameAsPath)"

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
        write-host "Update $file package :$package"  -foreground 'magenta'
        $fullName = $file.FullName
        Invoke-Expression "dotnet add $fullName package $package"
    }
}