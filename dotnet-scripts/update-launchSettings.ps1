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
    $filePath = "$($ProjectFolder)\Properties\launchSettings.json"
    Write-Output "Updating the $($filePath) file." | WriteColour("DarkMagenta")

    $fileContent = Get-Content -Path $filePath | ConvertFrom-Json
    
    $fileContent.PSObject.Properties.Remove('iisSettings')
    foreach ($currentItemName in $($fileContent.profiles)) {
        $currentItemName.PSObject.Properties.Remove('http')
        $currentItemName.PSObject.Properties.Remove('IIS Express')
        $currentItemName.https.applicationUrl = $currentItemName.https.applicationUrl.split(";")[0]
    }
    
    $fileContent = $fileContent | ConvertTo-Json
    $fileContent | Set-Content -Path $filePath
    Write-Output "Updated the $($filePath) file." | WriteColour("Green")
}

end {

}