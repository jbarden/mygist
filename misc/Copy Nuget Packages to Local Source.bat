cd c:\
cd repos
ForFiles /P . /M *.*nupkg /S /C "cmd /c copy @file c:\local-nuget\"
pause