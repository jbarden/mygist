[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$ProjectFolder
)

begin {
}

process{    
    WriteColour -Message "Removing the *.development.json file." -Colour "Magenta"
    Remove-Item "$($ProjectFolder)\*" -Include *.development.json -Recurse
    WriteColour -Message "Removed the *.development.json file." -Colour "Green"

    $filePath = "$($ProjectFolder)\Program.cs"
    WriteColour -Message "Updating the $($filePath) file." -Colour "Magenta"
    $fileContent = Get-Content -Path $filePath
    
    $fileContent = $fileContent.Replace("// Add services to the container.", "")
    $fileContent = $fileContent.Replace("// Configure the HTTP request pipeline.", "")
    $fileContent = $fileContent.Replace("// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle", "")
    $fileContent = $fileContent.Replace("app.UseHttpsRedirection();", "")
 
    $textToReplace = "var app = builder.Build();"
    $newText = "_ = builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
_ = builder.UseSerilogLogging();

var app = builder.Build();"
    
    $fileContent = $fileContent.Replace($textToReplace, $newText)
    $fileContent = $fileContent.Replace("

    ", "")
    $fileContent | Set-Content -Path $filePath
    
    @("") + (Get-Content $($filePath)) | Set-Content $($filePath)
    @("using AStar.ASPNet.Extensions.Handlers;") + (Get-Content $($filePath)) | Set-Content $($filePath)
    @("using AStar.Logging.Extensions;") + (Get-Content $($filePath)) | Set-Content $($filePath)
    
    WriteColour -Message "Updated the $($filePath) file." -Colour "Magenta"

    & "$PSScriptRoot\update-launchSettings.ps1" -ProjectFolder "$($ProjectFolder)"
}

end {
    WriteColour -Message "Completed project updates for Blazor Bootstrap." -Colour "Green"
}
