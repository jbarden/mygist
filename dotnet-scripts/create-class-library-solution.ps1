# run the below from the dotnet-scripts folder or update the initial path  
#.\Create-Class-Library-Solution.ps1 -RootDirectory c:\repos\mine -SolutionName AStar.ASPNet.Extensions

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage='Please specify the root directory to use to create the new solution.')]
    [string]$RootDirectory,
    [Parameter(Mandatory = $true, HelpMessage='Please specify the solution name, this will be used to create the solution file and all associated projects.')]
    [string]$SolutionName,
    [Parameter(Mandatory = $false, HelpMessage = 'Please specify the bearer token to access GitHub with.')]
    [string]$BearerToken,
    [Parameter(Mandatory = $true, HelpMessage = 'Please specify the description for the repository.')]
    [string]$Description,
    [Parameter(Mandatory = $false, HelpMessage = 'Please specify the owner / organisation for the repository.')]
    [string]$Owner = "astar-development",
    [Parameter(HelpMessage='Specifies whether the GIT repo should be initialised. The default is true.')]
    [bool]$CreateAndConfigureGitHubRepo = $true,
    [Parameter(HelpMessage='Specifies whether the solution should be configured as a NuGet package. The default is false.')]
    [bool]$MakeNuGetPackage = $false,
    [Parameter(Mandatory = $false, HelpMessage='Please specify the NuGet Description, this will be used to create the NuGet package details.')]
    [string]$NuGetDescription = 'Please update this description.',
    [Parameter(Mandatory = $false, HelpMessage='Please specify the Release Notes, this will be used to create the NuGet package details.')]
    [string]$ReleaseNotes = 'Version 0.1.0 is the initial version. There are no changes.',
    [Parameter(Mandatory = $false, HelpMessage='Please specify the NuGet version, this will be used to create the NuGet package details.')]
    [string]$NuGetVersion = '0.1.0',
    [Parameter(HelpMessage='Controls whether to redploy (i.e. remove all existing files) the template. The default is, for safety, $false.')]
    [bool]$Redeploy = $false,
    [Parameter(HelpMessage='Controls whether to launch the new solution. The default is, for the sake of speed, $false.')]
    [bool]$LaunchOnCompletion = $false
)

begin{
    $startTime = Get-Date
    $StartingFolder = Get-Location
    $SolutionNameAsPath = $SolutionName.Replace(".", "-").ToLower()
    $BaseSolutionDirectory = "$($RootDirectory)\$($SolutionNameAsPath)"
    Import-Module -Name RemovePreviousSolution -Force
    Import-Module -Name WriteColour -Force
    Import-Module -Name CreateInitialSolution -Force
    Import-Module -Name WarningsAsErrors -Force
    Import-Module -Name EndOutput -Force
    Import-Module -Name GitHubPipelines -Force
    Import-Module -Name CommitInitialSolution -Force

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

        CreateInitialSolution -BaseSolutionDirectory $BaseSolutionDirectory -ProjectName $SolutionName -SolutionName $SolutionName -CreateUiDirectories $false -CreateAndConfigureGitHubRepo $CreateAndConfigureGitHubRepo -CreateClassLibrary $true -BearerToken $BearerToken -Owner $Owner -StartingFolder $StartingFolder -Description $Description
        
        Set-Location $BaseSolutionDirectory
        dotnet new classlib --name "$($SolutionName)" --output "$($RootDirectory)\$($SolutionNameAsPath)\src\$SolutionName"
        dotnet sln "$($BaseSolutionDirectory)\$SolutionFile" add "$($BaseSolutionDirectory)\src\$SolutionName"
        dotnet add "$($RootDirectory)\$($SolutionNameAsPath)\tests\unit\$SolutionName.Unit.Tests\$SolutionName.Unit.Tests.csproj" reference "$($RootDirectory)\$($SolutionNameAsPath)\src\$SolutionName\$SolutionName.csproj"
        WriteColour -Message "Add Class Library reference to the Unit Test project." -Colour "Magenta"

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
                    -SolutionName "$($SolutionName)" -GitHubProject "$($SolutionNameAsPath)" -NuGetVersion "$($NuGetVersion)" -NuGetDescription "$($NuGetDescription)" `
                    -ReleaseNotes "$($ReleaseNotes)" -Owner $Owner
                 
            & "$PSScriptRoot\readme-updates.ps1" -SolutionDirectory $BaseSolutionDirectory -SolutionNameAsPath "$($SolutionNameAsPath)" -SolutionName "$($SolutionName)"

            WriteColour -Message "Updated the $($SolutionName) project file to become a NuGet package." -Colour 'Green'
            xcopy $StartingFolder\..\nuget-pipelines\nuget-package\.github $BaseSolutionDirectory\.github\ /Y /S
        } else {
            xcopy $StartingFolder\..\nuget-pipelines\class-library\.github $BaseSolutionDirectory\.github\ /Y /S
        }

        
        remove-item * -Include Class1.cs -recurse -force
        CommitInitialSolution -BaseSolutionDirectory $BaseSolutionDirectory -SolutionNameAsPath $SolutionNameAsPath -BearerToken $BearerToken -SolutionName $SolutionName -Owner $Owner
    }
    finally {
        Set-Location "$($StartingFolder)"
    }
}

end{
    EndOutput -startTime "$($startTime)"
    if($LaunchOnCompletion) {
         WriteColour -Message "Opening the $($SolutionFileWithPath) solution." -Colour 'Green'
        & 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe' $SolutionFileWithPath
    }
}
