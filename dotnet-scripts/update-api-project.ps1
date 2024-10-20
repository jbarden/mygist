[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Please specify the root directory for the new solution.')]
    [string]$ProjectFolder,
    [Parameter(Mandatory = $true, HelpMessage = 'Please specify the project name for the new solution.')]
    [string]$ProjectName
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
    $fileContent = Get-Content -Path $filePath -Raw
    
    $fileContent = $fileContent.Replace("{ProjectName}", "$($ProjectName)")
    $fileContent | Set-Content -Path $filePath
    
    WriteColour -Message "Updated the $($filePath) file." -Colour "Green"

    & "$PSScriptRoot\update-launchSettings.ps1" -ProjectFolder "$($ProjectFolder)"
}

end {
    WriteColour -Message "Completed project updates for Blazor Bootstrap." -Colour "Green"
}
