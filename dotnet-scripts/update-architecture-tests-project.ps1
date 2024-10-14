[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the project folder to use for the new solution.')]
    [string]$ProjectFolder,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the Architecture Test Namespace for the new solution.')]
    [string]$ArchitectureTestNamespace,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the UI Project Name for the new solution.')]
    [string]$UIProjectName,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the API Project Name for the new solution.')]
    [string]$APIProjectName,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the Domain Project Name for the new solution.')]
    [string]$DomainProjectName,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the Infrastructure Project Name for the new solution.')]
    [string]$InfrastructureProjectName
)

begin {
    
}

process{    
    WriteColour -Message "Updating $($ProjectFolder)." -Colour "Magenta"

    $filePath = "$($ProjectFolder)\ArchitectureLayersShould.cs"
    WriteColour -Message "Updating the $($filePath) file." -Colour "Magenta"
    $fileContent = Get-Content -Path $filePath
    
    $fileContent = $fileContent.Replace("{ArchitectureNamespace}", "$($ArchitectureTestNamespace)")
    $fileContent = $fileContent.Replace("{UiName}", "$($UIProjectName)")
    $fileContent = $fileContent.Replace("{ApiName}", "$($APIProjectName)")
    $fileContent = $fileContent.Replace("{DomainModel}", "$($DomainProjectName)")
    $fileContent = $fileContent.Replace("{InfrastructureName}", "$($InfrastructureProjectName)")
    
    $fileContent | Set-Content -Path $filePath
    
    WriteColour -Message "Updated the $($filePath) file." -Colour "Magenta"
}

end {
    WriteColour -Message "Completed project updates for Blazor Bootstrap." -Colour "Green"
}
