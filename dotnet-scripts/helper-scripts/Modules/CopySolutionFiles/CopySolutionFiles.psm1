function CopySolutionFiles {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$BaseSolutionDirectory
    )
    
    WriteColour -Message "Copying files." -Colour "Magenta"
    
    if(Test-Path -Path "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"){
        xcopy .\nuget.config "$($BaseSolutionDirectory)\src\api\$($APIProjectName)" /Y
    }

    xcopy .\.editorconfig $BaseSolutionDirectory /Y
    xcopy .\CodeMaid.config $BaseSolutionDirectory /Y
    xcopy .\.git* $BaseSolutionDirectory /Y
    WriteColour -Message "Completed copying files." -Colour "Green"
}

Export-ModuleMember -Function CopySolutionFiles