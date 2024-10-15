# run the below from the dotnet-scripts folder or update the initial path  
#.\Create-Class-Library-Solution.ps1 -RootDirectory c:\repos\mine -SolutionName AStar.ASPNet.Extensions

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage='Specify the root directory to use to create the new solution.')]
    [string]$RootDirectory,
    [Parameter(Mandatory = $true, HelpMessage='Specify the solution name, this will be used to create the solution file and all associated projects.')]
    [string]$SolutionName,
    [Parameter(HelpMessage='Specifies whether the GIT repo should be initialised. The default is true.')]
    [bool]$ConfigureGit = $true,
    [Parameter(HelpMessage='Specifies whether the solution should be configured as a NuGet package. The default is false.')]
    [bool]$MakeNuGetPackage = $false,
    [Parameter(Mandatory = $false, HelpMessage='Specify the NuGet Description, this will be used to create the NuGet package details.')]
    [string]$NuGetDescription = 'Please update this description.',
    [Parameter(Mandatory = $false, HelpMessage='Specify the Release Notes, this will be used to create the NuGet package details.')]
    [string]$ReleaseNotes = 'Version 0.1.0 is the initial version. There are no changes.',
    [Parameter(Mandatory = $false, HelpMessage='Specify the NuGet version, this will be used to create the NuGet package details.')]
    [string]$NuGetVersion = '0.1.0',
    [Parameter(HelpMessage='Controls whether to redploy (i.e. remove all existing files) the template. The default is, for safety, $false.')]
    [bool]$Redeploy = $false
)

begin{
    $startTime = Get-Date
    $StartingFolder = Get-Location
    $SolutionNameAsPath = $SolutionName.Replace(".", "-").ToLower()
    $BaseSolutionDirectory = "$($RootDirectory)\$($SolutionNameAsPath)"
    $GitHubProject = $SolutionNameAsPath
    Import-Module -Name RemovePreviousSolution -Force
    Import-Module -Name WriteColour -Force
    Import-Module -Name CreateInitialSolution -Force
    Import-Module -Name WarningsAsErrors -Force
    Import-Module -Name EndOutput -Force

    function ReadFilePreservingLineBreaks($path) {
        (Get-Content -Path $path -Raw) + [Environment]::NewLine + [Environment]::NewLine
    }
}

process{
    try {
        WriteColour -Message "Starting the Class Library creation" -Colour "Green"
        if($Redeploy) {
            RemovePreviousSolution -BaseSolutionDirectory $BaseSolutionDirectory
        }

        CreateInitialSolution -BaseSolutionDirectory $BaseSolutionDirectory -ProjectName $SolutionName -SolutionName $SolutionName -CreateUiDirectories $false -ConfigureGit $ConfigureGit -CreateClassLibrary $true
        
        Set-Location $BaseSolutionDirectory
        dotnet new classlib --name "$($SolutionName)" --output "$($RootDirectory)\$($SolutionNameAsPath)\src\$SolutionName"
        dotnet sln "$($BaseSolutionDirectory)\$SolutionFile" add "$($BaseSolutionDirectory)\src\$SolutionName"
    
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
                WriteColour -Message "Updating $file package :$package" -Colour 'Magenta'
                $fullName = $file.FullName
                Invoke-Expression "dotnet add $fullName package $package"
            }
        }

        WarningsAsErrors -BaseSolutionDirectory $BaseSolutionDirectory -StartingFolder $StartingFolder

        if($MakeNuGetPackage) {
            & "$PSScriptRoot\nuget-project-file-updates.ps1" -RootDirectory "$($RootDirectory)" -SolutionNameAsPath "$($SolutionNameAsPath)" `
                    -SolutionName "$($SolutionName)" -GitHubProject "$($GitHubProject)" -NuGetVersion "$($NuGetVersion)" -NuGetDescription "$($NuGetDescription)" `
                    -ReleaseNotes "$($ReleaseNotes)"
                 
            & "$PSScriptRoot\readme-updates.ps1" -SolutionDirectory $BaseSolutionDirectory -SolutionNameAsPath "$($SolutionNameAsPath)" -SolutionName "$($SolutionName)"

            WriteColour -Message "Updated the $($SolutionName) project file to become a NuGet package." -Colour 'Green'
        }
    }
    finally {
        Set-Location "$($StartingFolder)"
    }
}

end{
    EndOutput -startTime "$($startTime)"
}
