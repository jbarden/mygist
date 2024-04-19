[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$ProjectFolder
)

begin {
    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process {
    Write-Output "Updating the $($ProjectFolder)\Properties\launchSettings.json file." | WriteColour("DarkMagenta")
    $filePath = "$($ProjectFolder)\Properties\launchSettings.json"

    $fileContent = Get-Content -Path $filePath | ConvertFrom-Json
    
    $fileContent.PSObject.Properties.Remove('iisSettings')
    foreach ($currentItemName in $($fileContent.profiles)) {
        $currentItemName.PSObject.Properties.Remove('http')
        $currentItemName.PSObject.Properties.Remove('IIS Express')
        $currentItemName.https.applicationUrl = $currentItemName.https.applicationUrl.split(";")[0]
    }
    
    $fileContent = $fileContent | ConvertTo-Json
    $fileContent | Set-Content -Path $filePath
    Write-Output "Updated the $($ProjectFolder)\Properties\launchSettings.json file." | WriteColour("Green")
}

end {

}