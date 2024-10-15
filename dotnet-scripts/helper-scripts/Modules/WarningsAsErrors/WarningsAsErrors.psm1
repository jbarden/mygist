function WarningsAsErrors {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$BaseSolutionDirectory,
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the Starting Folder that contains the required file(s).')]
        [string]$StartingFolder
    )

    Import-Module -Name WriteColour -Force
    $projectFiles = Get-ChildItem -Path $BaseSolutionDirectory -Filter *.csproj -Recurse
    $newText = Get-Content -Path "$($StartingFolder)\helper-scripts\Modules\WarningsAsErrors\warnings-as-errors.txt" -Raw
    $newText

    foreach ($filePath in $projectFiles) {
        WriteColour -Message "Updating the $($filePath) file to treat warnings as errors." -Colour "Magenta"
        $fileContent = Get-Content -Path $filePath -Raw
        $textToReplace = "</Project>"
        
        $fileContent = $fileContent.Replace($textToReplace, $newText)
        $fileContent | Set-Content -Path $filePath
        WriteColour -Message "Updated the $($filePath) file to treat warnings as errors." -Colour "Green"
    }
}

Export-ModuleMember -Function WarningsAsErrors