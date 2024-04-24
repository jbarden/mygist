function CopySolutionFiles {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$BaseSolutionDirectory,
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$APIProjectName,
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$SolutionName
    )
    
    WriteColour -Message "Copying files." -Colour "Magenta"
    
    if(Test-Path -Path "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"){
        xcopy .\nuget.config "$($BaseSolutionDirectory)\src\api\$($APIProjectName)" /Y
    }

    xcopy .\.editorconfig $BaseSolutionDirectory /Y
    xcopy .\CodeMaid.config $BaseSolutionDirectory /Y
    xcopy .\.git* $BaseSolutionDirectory /Y
    xcopy .\README.md $BaseSolutionDirectory /Y

    $filePath = "$($BaseSolutionDirectory)\readme.md"
        
    $fileContent = Get-Content -Path $filePath

    $updatedSolutionName = $SolutionName.Replace(".", "-")
    $fileContent = $fileContent.Replace("{SolutionName}", "$($updatedSolutionName)")

    $fileContent | Set-Content -Path $filePath
    WriteColour -Message "Completed copying files." -Colour "Green"
}

Export-ModuleMember -Function CopySolutionFiles