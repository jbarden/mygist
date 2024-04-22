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
    ForFiles /P . /M *.*nupkg /S /C "cmd /c copy @file c:\local-nuget\"
    Set-Location $currentLocation

    if($ClearNuGetCache){
        $userHome = $env:USERPROFILE
        Write-Output "Starting to clear the NuGet Cache." | WriteColour("Magenta")
        
        if(Test-Path -Path $userHome\.nuget\packages){
            Remove-Item -Recurse -Force $userHome\.nuget\packages
            Write-Output "Cleared the NuGet Cache." | WriteColour("Green")
        }
        else {
            Write-Output "NuGet cache does not exist." | WriteColour("Green")
        }        
    }
}

end {

}