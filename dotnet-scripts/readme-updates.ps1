[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Please specify the Solution Directory.')]
    [string]$SolutionDirectory,
    [Parameter(Mandatory = $true, HelpMessage = 'Please specify the Solution Name as path.')]
    [string]$SolutionNameAsPath,
    [Parameter(Mandatory = $true, HelpMessage = 'Please specify the Solution Name.')]
    [string]$SolutionName
)

begin {
    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process{ 
    $readmeLocation = "$($SolutionDirectory)\readme.md"
    $fileContent = Get-Content -Path $readmeLocation -Raw
    $fileContent = $fileContent.Replace('{SolutionName}', $SolutionName)
    $fileContent = $fileContent.Replace('{SolutionNameAsPath}', $SolutionNameAsPath)
    $fileContent | Set-Content -Path $readmeLocation
}

end {

}