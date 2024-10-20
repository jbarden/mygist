[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the Root Directory.')]
    [string]$RootDirectory,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the Solution Name as path.')]
    [string]$SolutionNameAsPath,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the Solution Name.')]
    [string]$SolutionName,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the Solution Owner.')]
    [string]$Owner,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the GitHub Project Name.')]
    [string]$GitHubProject,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the NuGet Version.')]
    [string]$NuGetVersion,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the NuGet Description.')]
    [string]$NuGetDescription,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the Release Notes.')]
    [string]$ReleaseNotes
)

begin {
    
}

process { 
    $coreProjectLocation = "$($RootDirectory)\$($SolutionNameAsPath)\src\$SolutionName\$SolutionName.csproj"
    $fileContent = Get-Content -Path $coreProjectLocation -Raw
    $textToReplace = "</Project>"

    $newText = ReadFilePreservingLineBreaks("$StartingFolder\nuget\NuGet.PropertyGroup.txt")
    $newText = $newText.Replace('{CopyrightYear}', (Get-Date).Year)
    $newText = $newText.Replace('{PackageTitle}', $SolutionName)
    $newText = $newText.Replace('{GitHubProject}', $GitHubProject)
    $newText = $newText.Replace('{Owner}', $Owner)
    $newText = $newText.Replace('{NuGetVersion}', $NuGetVersion)
    $newText = $newText.Replace('{Description}', $NuGetDescription)
    $newText = $newText.Replace('{ReleaseNotes}', $ReleaseNotes)
    $fileContent = $fileContent.Replace($textToReplace, $newText + $textToReplace)

    $newText = ReadFilePreservingLineBreaks("$StartingFolder\nuget\NuGet.Package.ItemGroup.txt")
    $fileContent = $fileContent.Replace($textToReplace, $newText + $textToReplace)
    $fileContent | Set-Content -Path $coreProjectLocation

    $targetDirectory = "$($RootDirectory)\$($SolutionNameAsPath)"
    xcopy $StartingFolder\nuget\AStar.png $TargetDirectory /Y
    xcopy $StartingFolder\nuget\LICENSE $TargetDirectory /Y

    xcopy $StartingFolder\README.md $TargetDirectory /Y
}

end {

}