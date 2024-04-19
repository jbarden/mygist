[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$BaseDirectory,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$UIProjectPath,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$APIProjectPath
)

begin {
    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process{    
    Write-Output "Removing the *.development.json files." | WriteColour("DarkMagenta")
    Remove-Item "$($BaseDirectory)\*" -Include *.development.json -Recurse
    Write-Output "Removed the *.development.json files." | WriteColour("Green")

    Write-Output "Updating the $($APIProjectPath)\Program.cs file." | WriteColour("DarkMagenta")
    $filePath = "$($APIProjectPath)\Program.cs"
    
    $textToReplace = 'app.UseHttpsRedirection();'
    $fileContent = Get-Content -Path $filePath

    $fileContent = $fileContent.Replace($textToReplace, '')
    $fileContent | Set-Content -Path $filePath
    Write-Output "Updated the $($APIProjectPath)\Program.cs file." | WriteColour("Green")
}

end {
    Write-Output "Completed project updates for Blazor Bootstrap." | WriteColour("Green")
}
