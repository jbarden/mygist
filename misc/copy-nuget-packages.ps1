$currentLocation = Get-Location
Set-Location C:\repos
ForFiles /P . /M *.*nupkg /S /C "cmd /c copy @file c:\local-nuget\"
Set-Location $currentLocation