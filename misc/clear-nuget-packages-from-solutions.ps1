[CmdletBinding()]
Param (
    [Parameter(HelpMessage='Controls whether to clear the local NuGet cache and thus ensure the next build of any project gets the latest, greatest, version of any AStar NuGet package. The default is, for the sake of speed, $false.')]
    [bool]$ClearNuGetCache = $false
)

begin{
    $currentLocation = Get-Location

    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process{
    Set-Location C:\repos
    ForFiles /P . /M *.*nupkg /S /C "cmd /c del @file"
    Set-Location $currentLocation
}

end {

}