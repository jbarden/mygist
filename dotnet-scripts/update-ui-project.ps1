[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory of the UI Project, not the overarching root directory for the new solution.')]
    [string]$ProjectFolder
)

begin {
    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process{
    Write-Output "Starting UI Project updates." | WriteColour("Magenta")
    
    Write-Output "Removing the *.development.json file." | WriteColour("Magenta")
    Remove-Item "$($ProjectFolder)\*" -Include *.development.json -Recurse
    Write-Output "Removed the *.development.json file." | WriteColour("Green")

    Write-Output "Updating app.razor." | WriteColour("Magenta")
    
    $filePath = "$($ProjectFolder)\components\app.razor"
    
    $textToReplace = '<html lang="en">'
    $newText = '<html lang="en" data-bs-theme="dark">'
    
    $fileContent = Get-Content -Path $filePath
    $fileContent = $fileContent -replace $textToReplace, $newText
    
    $textToReplace = '<base href="/" />'
    $newText = '<base href="/" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="_content/Blazor.Bootstrap/blazor.bootstrap.css" rel="stylesheet" />'
    
    $fileContent = $fileContent -replace $textToReplace, $newText

    $textToReplace = '<Routes />'
    $newText = '<Routes @rendermode="InteractiveServer" />'
    
    $fileContent = $fileContent -replace $textToReplace, $newText
    
    $textToReplace = '<script src="_framework/blazor.web.js"></script>'
    $newText = '<script src="_framework/blazor.web.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
    <!-- Add chart.js reference if chart components are used in your application. -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.0.1/chart.umd.js" integrity="sha512-gQhCDsnnnUfaRzD8k1L5llCCV6O9HN09zClIzzeJ8OJ9MpGmIlCxm+pdCkqTwqJ4JcjbojFr79rl2F1mzcoLMQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    <!-- Add chartjs-plugin-datalabels.min.js reference if chart components with data label feature is used in your application. -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/chartjs-plugin-datalabels/2.2.0/chartjs-plugin-datalabels.min.js" integrity="sha512-JPcRR8yFa8mmCsfrw4TNte1ZvF1e3+1SdGMslZvmrzDYxS69J7J49vkFL8u6u8PlPJK+H3voElBtUCzaXj+6ig==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    <!-- Add sortable.js reference if SortableList component is used in your application. -->
    <script src="https://cdn.jsdelivr.net/npm/sortablejs@latest/Sortable.min.js"></script>
    <script src="_content/Blazor.Bootstrap/blazor.bootstrap.js"></script>'
    
    $fileContent = $fileContent -replace $textToReplace, $newText
    
    $textToReplace = '<link rel="stylesheet" href="bootstrap/bootstrap.min.css" />'
    
    $fileContent = $fileContent -replace $textToReplace, ''
    
    $fileContent | Set-Content -Path $filePath
    Write-Output "Updated app.razor." | WriteColour("Green")
    
    $bootstrapFolder = "$($ProjectFolder)\wwwroot\bootstrap"
    remove-item $bootstrapFolder -recurse -force

    $filePath = "$($ProjectFolder)\components\_Imports.razor"
    Write-Output "Updating the $($filePath) file." | WriteColour("Magenta")
    @("@using BlazorBootstrap;") + (Get-Content $($filePath)) | Set-Content $($filePath)
    Write-Output "Updated the $($filePath) file." | WriteColour("Green")

    $filePath = "$($ProjectFolder)\program.cs"    
    Write-Output "Updating the $($filePath) file." | WriteColour("Magenta")
    $textToReplace = "var app = builder.Build();"
    $newText = "builder.Services.AddBlazorBootstrap();
builder.Services.AddGlobalExceptionHandler();
var app = builder.Build();"
    
    $fileContent = Get-Content -Path $filePath
    $fileContent = $fileContent.Replace($textToReplace, $newText)
    $fileContent = $fileContent.Replace("// Add services to the container.", "")
    $fileContent = $fileContent.Replace("// Configure the HTTP request pipeline.", "")
    $fileContent = $fileContent.Replace("// The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.", "")
    
    $fileContent | Set-Content -Path $filePath
    @("using AStar.ASPNet.Extensions.Handlers;") + (Get-Content $($filePath)) | Set-Content $($filePath)
    Write-Output "Updated the $($filePath) file." | WriteColour("Green")

    Write-Output "Copying Layout and NavMenu files to $($ProjectFolder)\components\Layout\." | WriteColour("Magenta")
    xcopy ".\components\Layout\*.*" "$($($ProjectFolder))\components\Layout\" /Y
    Write-Output "Completed copying Layout and NavMenu files." | WriteColour("Green")
    & "$PSScriptRoot\update-launchSettings.ps1" -ProjectFolder "$($ProjectFolder)"
}

end {
    Write-Output "Completed project updates for Blazor Bootstrap." | WriteColour("Green")
}
