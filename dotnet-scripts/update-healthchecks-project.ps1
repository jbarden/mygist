[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory of the HealthChecks Project, not the overarching root directory for the new solution.')]
    [string]$ProjectFolder,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory of the HealthChecks Project, not the overarching root directory for the new solution.')]
    [string]$SolutionName
)

begin {
    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process{
    Write-Output "Starting HealthChecks Project updates." | WriteColour("Magenta")
    
    Write-Output "Removing the Class1.cs file." | WriteColour("Magenta")
    Remove-Item "$($ProjectFolder)\*" -Include Class1.cs -Recurse
    Write-Output "Removed the Class1.cs file." | WriteColour("Green")

    Write-Output "Copying the HealthCheckResponses.cs file to $($ProjectFolder)." | WriteColour("Magenta")
    xcopy ".\HealthCheck-Files\*.*" "$($ProjectFolder)" /Y
    Write-Output "Completed copying the HealthCheckResponses.cs file." | WriteColour("Green")

    Write-Output "Updating the HealthCheckResponses.cs file." | WriteColour("Magenta")
    
    $filePath = "$($ProjectFolder)\HealthCheckResponses.cs."
    
    $textToReplace = '{SolutionName}'
    
    $fileContent = Get-Content -Path $filePath
    $fileContent = $fileContent -replace $textToReplace, $SolutionName
    
    $fileContent | Set-Content -Path $filePath
    Write-Output "Updated the HealthCheckResponses.cs file." | WriteColour("Green")
}

end {
    Write-Output "Completed project updates for Blazor Bootstrap." | WriteColour("Green")
}
