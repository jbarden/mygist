function CopySolutionFiles {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory of the new solution.')]
        [string]$BaseSolutionDirectory,
        [Parameter(Mandatory = $true, HelpMessage = 'The project name within the new solution.')]
        [string]$ProjectName,
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the name of the new solution.')]
        [string]$SolutionName
    )
    
    Import-Module -Name WriteColour -Force
    WriteColour -Message "Copying files." -Colour "Magenta"
    
    if(Test-Path -Path "$($BaseSolutionDirectory)\src\api\$($ProjectName)"){
        xcopy .\nuget\nuget.config "$($BaseSolutionDirectory)\src\api\$($ProjectName)" /Y
    }

    xcopy .\.editorconfig $BaseSolutionDirectory /Y
    xcopy .\CodeMaid.config $BaseSolutionDirectory /Y
    xcopy .\.git* $BaseSolutionDirectory /Y
    xcopy .\README.md $BaseSolutionDirectory /Y

    $filePath = "$($BaseSolutionDirectory)\readme.md"
        
    $fileContent = Get-Content -Path $filePath -Raw

    $updatedSolutionName = $SolutionName.Replace(".", "-")
    $fileContent = $fileContent.Replace("{SolutionName}", "$($updatedSolutionName)")

    $fileContent | Set-Content -Path $filePath
    WriteColour -Message "Completed copying files." -Colour "Green"
}

Export-ModuleMember -Function CopySolutionFiles