# run the below from the dotnet-scripts folder or update the initial path  
#.\Create-Class-Library-Solution.ps1 -RootDirectory c:\repos\mine -SolutionName AStar.ASPNet.Extensions

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage='Specify the root directory to use to create the new solution.')]
    [string]$RootDirectory,
    [Parameter(Mandatory = $true, HelpMessage='Specify the solution name, this will be used to create the solution file and all associated projects.')]
    [string]$SolutionName
)

begin{
    $startTime = Get-Date
    $StartingFolder = Get-Location
    $SolutionFile = "$($SolutionName).sln"
    $SolutionNameAsPath = $SolutionName.Replace(".", "-").ToLower()}

process{
    try {
        mkdir "$($RootDirectory)\$($SolutionNameAsPath)"
        Copy-Item ..\.gitignore -Destination "$($RootDirectory)\$($SolutionNameAsPath)"
        Set-Location "$($RootDirectory)\$($SolutionNameAsPath)"
        git init --initial-branch=main
        mkdir "$($RootDirectory)\$($SolutionNameAsPath)\src"
        mkdir "$($RootDirectory)\$($SolutionNameAsPath)\tests\unit"
        
        dotnet new sln --name "$($SolutionName)" --output "$($RootDirectory)\$($SolutionNameAsPath)"
        dotnet new classlib --name "$($SolutionName)" --output "$($RootDirectory)\$($SolutionNameAsPath)\src\$SolutionName"
        dotnet sln "$($RootDirectory)\$($SolutionNameAsPath)\$SolutionFile" add "$($RootDirectory)\$($SolutionNameAsPath)\src\$SolutionName"
        
        dotnet new xunit --name "$($SolutionName).Unit.Tests" --output "$($RootDirectory)\$($SolutionNameAsPath)\tests\unit\$($SolutionName).Unit.Tests"
        dotnet add "$($RootDirectory)\$($SolutionNameAsPath)\tests\unit\$($SolutionName).Unit.Tests\$($SolutionName).Unit.Tests.csproj" reference "$($RootDirectory)\$($SolutionNameAsPath)\src\$($SolutionName)"
        dotnet sln "$($RootDirectory)\$($SolutionNameAsPath)\$SolutionFile" add "$($RootDirectory)\$($SolutionNameAsPath)\tests\unit\$($SolutionName).Unit.Tests"
        
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
                write-host "Update $file package :$package"  -foreground 'Magenta'
                $fullName = $file.FullName
                Invoke-Expression "dotnet add $fullName package $package"
            }
        }
    }
    finally {
        Set-Location "$($StartingFolder)"
    }
}

end{
    $endTime = Get-Date
    $duration = New-TimeSpan -Start $startTime -End $endTime
    WriteColour -Message "Start time: $($startTime)." -Colour "DarkYellow"
    WriteColour -Message "End time: $($endTime)." -Colour "DarkYellow"
    WriteColour -Message "Total processing time: $($duration.TotalMinutes) minutes." -Colour "Green"    
}
