[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Please specify the root directory to use to create the new solution.')]
    [string]$RootDirectory,
    [Parameter(Mandatory = $true, HelpMessage = 'Please specify the solution name, this will be used to create the solution file and all associated projects.')]
    [string]$SolutionName
)

begin {
    $SolutionNameAsPath = $SolutionName.Replace(".", "-").ToLower()
    $BaseSolutionDirectory = "$($RootDirectory)\$($SolutionNameAsPath)"

    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process {
    $projectFiles = Get-ChildItem -Path $BaseSolutionDirectory -Filter *.csproj -Recurse
    $newText = Get-Content -Path "warnings-as-errors.txt" -Raw
    $newText

    foreach ($filePath in $projectFiles) {
        Write-Output "Updating the $($filePath) file to treat warnings as errors." | WriteColour("Magenta")
        $fileContent = Get-Content -Path $filePath -Raw
        $textToReplace = "</Project>"
        
        $fileContent = $fileContent.Replace($textToReplace, $newText)
        $fileContent | Set-Content -Path $filePath
        Write-Output "Updated the $($filePath) file to treat warnings as errors." | WriteColour("Green")
    }
}

end {

}