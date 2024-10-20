[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Please specify the root directory to the launchSettings.json.')]
    [string]$ProjectFolder
)

begin {
}

process {
    $filePath = "$($ProjectFolder)\Properties\launchSettings.json"
    WriteColour -Message "Updating the $($filePath) file." -Colour "Magenta"

    $fileContent = Get-Content -Path $filePath | ConvertFrom-Json -Depth 10

    $fileContent.PSObject.Properties.Remove('iisSettings')
    foreach ($currentItemName in $($fileContent.profiles)) {
        $currentItemName.PSObject.Properties.Remove('http')
        $currentItemName.PSObject.Properties.Remove('IIS Express')
        $currentItemName.https.applicationUrl = $currentItemName.https.applicationUrl.split(";")[0]
    }

    $fileContent = $fileContent | ConvertTo-Json -Depth 10
    $fileContent | Set-Content -Path $filePath
    WriteColour -Message "Updated the $($filePath) file." -Colour "Green"
}

end {

}