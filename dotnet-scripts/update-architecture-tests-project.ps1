[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$ProjectFolder,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$ArchitectureTestNamespace,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$UIProjectName,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$APIProjectName,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$DomainProjectName,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$InfrastructureProjectName
)

begin {
    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process{    
    Write-Output "Updating $($ProjectFolder)." | WriteColour("Magenta")

    $filePath = "$($ProjectFolder)\ArchitectureLayersShould.cs"
    Write-Output "Updating the $($filePath) file." | WriteColour("Magenta")
    $fileContent = Get-Content -Path $filePath
    
    $fileContent = $fileContent.Replace("{ArchitectureNamespace}", "$($ArchitectureTestNamespace)")
    $fileContent = $fileContent.Replace("{UiName}", "$($UIProjectName)")
    $fileContent = $fileContent.Replace("{ApiName}", "$($APIProjectName)")
    $fileContent = $fileContent.Replace("{DomainModel}", "$($DomainProjectName)")
    $fileContent = $fileContent.Replace("{InfrastructureName}", "$($InfrastructureProjectName)")
    
    $fileContent | Set-Content -Path $filePath
    
    Write-Output "Updated the $($filePath) file." | WriteColour("Magenta")
}

end {
    Write-Output "Completed project updates for Blazor Bootstrap." | WriteColour("Green")
}
