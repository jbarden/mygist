[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$BaseDirectory,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$UIProjectPath,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$APIProjectPath
)

begin {
    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process{    
    Write-Output "Removing the *.development.json files." | WriteColour("DarkMagenta")
    Remove-Item "$($BaseDirectory)\*" -Include *.development.json -Recurse
    Write-Output "Removed the *.development.json files." | WriteColour("Green")

    $filePath = "$($APIProjectPath)\Program.cs"
    Write-Output "Updating the $($filePath) file." | WriteColour("DarkMagenta")
    $fileContent = Get-Content -Path $filePath
    
    $fileContent = $fileContent -replace 'app.UseHttpsRedirection();', ''

    $textToReplace = "var app = builder.Build();"
    $newText = "_ = builder.Services.AddGlobalExceptionHandler();
var app = builder.Build();"
    
    $fileContent = $fileContent.Replace($textToReplace, $newText)
    
    @("using AStar.ASPNet.Extensions.Handlers;") + (Get-Content $($filePath)) | Set-Content $($filePath)
    
    Write-Output "Updated the $($filePath) file." | WriteColour("DarkMagenta")

    $filePath = "$($UIProjectPath)\Program.cs"
    Write-Output "Updating the $($filePath) file." | WriteColour("DarkMagenta")
    $fileContent = Get-Content -Path $filePath

    $textToReplace = "var app = builder.Build();"
    $newText = "_ = builder.Services.AddGlobalExceptionHandler();
var app = builder.Build();"
    $fileContent = $fileContent.Replace($textToReplace, $newText)

    @("using AStar.ASPNet.Extensions.Handlers;") + (Get-Content $($filePath)) | Set-Content $($filePath)

    Write-Output "Updated the $($filePath) file." | WriteColour("DarkMagenta")

    & "$PSScriptRoot\update-launchSettings.ps1" -ProjectFolder "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
    & "$PSScriptRoot\update-launchSettings.ps1" -ProjectFolder "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"
}

end {
    Write-Output "Completed project updates for Blazor Bootstrap." | WriteColour("Green")
}
