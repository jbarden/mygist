[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$ProjectFolder,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$ApiProjectName
)

begin {
}

process{    
    WriteColour -Message "Removing the *.development.json file." -Colour "Magenta"
    Remove-Item "$($ProjectFolder)\*" -Include *.development.json -Recurse
    WriteColour -Message "Removed the *.development.json file." -Colour "Green"
    
    xcopy .\api-files\Program.cs "$($ProjectFolder)\" /Y /S
    $filePath = "$($ProjectFolder)\Program.cs"
    WriteColour -Message "Updating the $($filePath) file." -Colour "Magenta"
    $fileContent = Get-Content -Path $filePath
    
    $fileContent = $fileContent.Replace("{ApiProjectName}", "$($ApiProjectName)")
    $fileContent | Set-Content -Path $filePath
    
    WriteColour -Message "Updated the $($filePath) file." -Colour "Green"

    & "$PSScriptRoot\update-launchSettings.ps1" -ProjectFolder "$($ProjectFolder)"
}

end {
    WriteColour -Message "Completed project updates for Blazor Bootstrap." -Colour "Green"
}
