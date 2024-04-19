[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$UIProjectFolder
)

begin {
    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process{
    Write-Output "Starting project updates for Blazor Bootstrap." | WriteColour("magenta")
    Write-Output "Updating app.razor." | WriteColour("magenta")
    
    $filePath = "$($UIProjectFolder)\components\app.razor"
    
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
    
    $bootstrapFolder = "$($UIProjectFolder)\wwwroot\bootstrap"
    remove-item $bootstrapFolder -recurse -force
    Write-Output "Updated app.razor." | WriteColour("Green")
    
    Write-Output "Updating _Imports.razor." | WriteColour("magenta")
    $filePath = "$($UIProjectFolder)\components\_Imports.razor"
    $fileContent = Get-Content -Path $filePath
    $fileContent = $fileContent +'@using BlazorBootstrap;
'
    $fileContent | Set-Content -Path $filePath
    Write-Output "Updated _Imports.razor." | WriteColour("Green")
    
    Write-Output "Updating program.cs." | WriteColour("magenta")

    $filePath = "$($UIProjectFolder)\program.cs"

    $textToReplace = "var app = builder.Build();"
    $newText = "builder.Services.AddBlazorBootstrap();
var app = builder.Build();"
    
    $fileContent = Get-Content -Path $filePath
    $fileContent = $fileContent.Replace($textToReplace, $newText)
    
    $fileContent | Set-Content -Path $filePath
    Write-Output "Updated program.cs." | WriteColour("Green")

    Write-Output "Copying Layout and NavMenu files." | WriteColour("DarkMagenta")
    xcopy .\components\Layout\*.* "$($($UIProjectFolder))\components\Layout\" /Y
    Write-Output "Completed copying Layout and NavMenu files." | WriteColour("Green")
}

end {
    Write-Output "Completed project updates for Blazor Bootstrap." | WriteColour("Green")
}
