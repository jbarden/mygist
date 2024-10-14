[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the Solution Directory.')]
    [string]$SolutionDirectory,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the Solution Name as path.')]
    [string]$SolutionNameAsPath,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the Solution Name.')]
    [string]$SolutionName
)

begin {
    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process{ 
    $readmeLocation = "$($SolutionDirectory)\readme.md"
    $fileContent = Get-Content -Path $readmeLocation
    $fileContent = $fileContent.Replace('{SolutionName}', $SolutionName)
    $fileContent = $fileContent.Replace('{SolutionNameAsPath}', $SolutionNameAsPath)
    $fileContent | Set-Content -Path $readmeLocation
}

end {

}