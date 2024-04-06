#  .\Create.ps1 -RootDirectory c:\repos -ProjectName AStar.ASPNet.Extensions

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage='Specify the root directory to use to create the new solution.')]
    [string]$RootDirectory,
    [Parameter(Mandatory = $true, HelpMessage='Specify the project name, this will be used to create the solution file and all associated projects.')]
    [string]$ProjectName
)
$SolutionFile = "$($ProjectName).sln"
$ProjectNameAsPath = $ProjectName.Replace(".", "-").ToLower()

mkdir "$($RootDirectory)\$($ProjectNameAsPath)\src"
mkdir "$($RootDirectory)\$($ProjectNameAsPath)\tests\unit"
mkdir "$($RootDirectory)\$($ProjectNameAsPath)\tests\integration"
mkdir "$($RootDirectory)\$($ProjectNameAsPath)\tests\acceptance"
mkdir "$($RootDirectory)\$($ProjectNameAsPath)\tests\architecture"

dotnet new sln --name "$($ProjectName)" --output "$($RootDirectory)\$($ProjectNameAsPath)"
dotnet new classlib --name "$($ProjectName)" --output "$($RootDirectory)\$($ProjectNameAsPath)\src\$ProjectName"
dotnet sln "$($RootDirectory)\$($ProjectNameAsPath)\$SolutionFile" add "$($RootDirectory)\$($ProjectNameAsPath)\src\$ProjectName"

dotnet new xunit --name "$($ProjectName).Unit.Tests" --output "$($RootDirectory)\$($ProjectNameAsPath)\tests\unit\$($ProjectName).Unit.Tests"
dotnet add "$($RootDirectory)\$($ProjectNameAsPath)\tests\unit\$($ProjectName).Unit.Tests\$($ProjectName).Unit.Tests.csproj" reference "$($RootDirectory)\$($ProjectNameAsPath)\src\$($ProjectName)"
dotnet sln "$($RootDirectory)\$($ProjectNameAsPath)\$SolutionFile" add "$($RootDirectory)\$($ProjectNameAsPath)\tests\unit\$($ProjectName).Unit.Tests"

dotnet new xunit --name "$($ProjectName).Integration.Tests" --output "$($RootDirectory)\$($ProjectNameAsPath)\tests\integration\$($ProjectName).Integration.Tests"
dotnet add "$($RootDirectory)\$($ProjectNameAsPath)\tests\integration\$($ProjectName).Integration.Tests\$($ProjectName).Integration.Tests.csproj" reference "$($RootDirectory)\$($ProjectNameAsPath)\src\$($ProjectName)"
dotnet sln "$($RootDirectory)\$($ProjectNameAsPath)\$SolutionFile" add "$($RootDirectory)\$($ProjectNameAsPath)\tests\integration\$($ProjectName).Integration.Tests"

dotnet new xunit --name "$($ProjectName).Acceptance.Tests" --output "$($RootDirectory)\$($ProjectNameAsPath)\tests\acceptance\$($ProjectName).Acceptance.Tests"
dotnet add "$($RootDirectory)\$($ProjectNameAsPath)\tests\acceptance\$($ProjectName).Acceptance.Tests\$($ProjectName).Acceptance.Tests.csproj" reference "$($RootDirectory)\$($ProjectNameAsPath)\src\$($ProjectName)"
dotnet sln "$($RootDirectory)\$($ProjectNameAsPath)\$SolutionFile" add "$($RootDirectory)\$($ProjectNameAsPath)\tests\acceptance\$($ProjectName).Acceptance.Tests"

dotnet new xunit --name "$($ProjectName).Architecture.Tests" --output "$($RootDirectory)\$($ProjectNameAsPath)\tests\architecture\$($ProjectName).Architecture.Tests"
dotnet add "$($RootDirectory)\$($ProjectNameAsPath)\tests\architecture\$($ProjectName).Architecture.Tests\$($ProjectName).Architecture.Tests.csproj" reference "$($RootDirectory)\$($ProjectNameAsPath)\src\$($ProjectName)"
dotnet sln "$($RootDirectory)\$($ProjectNameAsPath)\$SolutionFile" add "$($RootDirectory)\$($ProjectNameAsPath)\tests\architecture\$($ProjectName).Architecture.Tests"

Set-Location "$($RootDirectory)\$($ProjectNameAsPath)"

$regex = 'PackageReference Include="([^"]*)" Version="([^"]*)"'

ForEach ($file in get-childitem . -recurse | where {$_.extension -like "*proj"})
{
    $packages = Get-Content $file.FullName |
        select-string -pattern $regex -AllMatches | 
        ForEach-Object {$_.Matches} | 
        ForEach-Object {$_.Groups[1].Value.ToString()}| 
        sort -Unique
    
    ForEach ($package in $packages)
    {
        write-host "Update $file package :$package"  -foreground 'magenta'
        $fullName = $file.FullName
        iex "dotnet add $fullName package $package"
    }
}