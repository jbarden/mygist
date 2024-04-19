[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$ProjectFolder
)

begin {
    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process{    
    Write-Output "Removing the *.development.json file." | WriteColour("Magenta")
    Remove-Item "$($ProjectFolder)\*" -Include *.development.json -Recurse
    Write-Output "Removed the *.development.json file." | WriteColour("Green")

    $filePath = "$($ProjectFolder)\Program.cs"
    Write-Output "Updating the $($filePath) file." | WriteColour("Magenta")
    $fileContent = Get-Content -Path $filePath
    
    $fileContent = $fileContent.Replace("// Add services to the container.", "")
    $fileContent = $fileContent.Replace("// Configure the HTTP request pipeline.", "")
    $fileContent = $fileContent.Replace("// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle", "")
    $fileContent = $fileContent.Replace("app.UseHttpsRedirection();", "")
    
    $textToReplace = "var app = builder.Build();"
    $newText = "_ = builder.Services.AddGlobalExceptionHandler();
var app = builder.Build();"
    
    $fileContent = $fileContent.Replace($textToReplace, $newText)
    $fileContent = $fileContent.Replace("

    ", "")
    $fileContent | Set-Content -Path $filePath
    
    @("using AStar.ASPNet.Extensions.Handlers;") + (Get-Content $($filePath)) | Set-Content $($filePath)
    
    Write-Output "Updated the $($filePath) file." | WriteColour("Magenta")

    & "$PSScriptRoot\update-launchSettings.ps1" -ProjectFolder "$($ProjectFolder)"
}

end {
    Write-Output "Completed project updates for Blazor Bootstrap." | WriteColour("Green")
}
