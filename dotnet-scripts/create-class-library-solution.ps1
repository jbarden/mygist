# run the below from the dotnet-scripts folder or update the initial path  
#.\Create-Class-Library-Solution.ps1 -RootDirectory c:\repos\mine -SolutionName AStar.ASPNet.Extensions

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage='Specify the root directory to use to create the new solution.')]
    [string]$RootDirectory,
    [Parameter(Mandatory = $true, HelpMessage='Specify the solution name, this will be used to create the solution file and all associated projects.')]
    [string]$SolutionName,
    [Parameter(HelpMessage='Specifies whether the solution shoulkd be configured as a NuGet package. The default is false.')]
    [bool]$MakeNuGetPackage = $false,
    [Parameter(Mandatory = $false, HelpMessage='Specify the NuGet Description, this will be used to create the NuGet package details.')]
    [string]$NuGetDescription = 'Please update this description.',
    [Parameter(Mandatory = $false, HelpMessage='Specify the Release Notes, this will be used to create the NuGet package details.')]
    [string]$ReleaseNotes = 'Version 0.1.0 is the initial version. There are no changes.',
    [Parameter(Mandatory = $false, HelpMessage='Specify the NuGet version, this will be used to create the NuGet package details.')]
    [string]$NuGetVersion = '0.1.0'
)

begin{
    $startTime = Get-Date
    $StartingFolder = Get-Location
    $SolutionFile = "$($SolutionName).sln"
    $SolutionNameAsPath = $SolutionName.Replace(".", "-").ToLower()
    $GitHubProject = $SolutionNameAsPath

    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }

    function ReadFilePreservingLineBreaks($path) {
        (Get-Content -Path $path -Raw) + [Environment]::NewLine + [Environment]::NewLine
    }
}

process{
    try {
        mkdir "$($RootDirectory)\$($SolutionNameAsPath)"
        Copy-Item ..\.gitignore -Destination "$($RootDirectory)\$($SolutionNameAsPath)"
        Set-Location "$($RootDirectory)\$($SolutionNameAsPath)"
        
        git init --initial-branch=main
        git config --global gpg.program "c:/Program Files (x86)/GnuPG/bin/gpg.exe"
        git config --global user.signingkey AF697941C147E382
        git config --global user.name "Jason Barden"
        git config --global user.email "jason.barden@outlook.com"
        git config --global commit.gpgsign true

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

        if($MakeNuGetPackage) {
            & "$PSScriptRoot\nuget-project-file-updates.ps1" -RootDirectory "$($RootDirectory)" -SolutionNameAsPath "$($SolutionNameAsPath)" `
                    -SolutionName "$($SolutionName)" -GitHubProject "$($GitHubProject)" -NuGetVersion "$($NuGetVersion)" -NuGetDescription "$($NuGetDescription)" `
                    -ReleaseNotes "$($ReleaseNotes)"
                 
            & "$PSScriptRoot\readme-updates.ps1" -SolutionDirectory "$($RootDirectory)\$($SolutionNameAsPath)" -SolutionNameAsPath "$($SolutionNameAsPath)" -SolutionName "$($SolutionName)"

            Write-Output "Updated the $($SolutionName) project file to become a NuGet package." | WriteColour("Green")
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
