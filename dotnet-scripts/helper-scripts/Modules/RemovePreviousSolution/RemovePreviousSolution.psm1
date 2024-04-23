function RemovePreviousSolution {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$BaseSolutionDirectory
    )

    WriteColour -Message "Removing the previous version located at $($BaseSolutionDirectory)." -Colour "Magenta"
    if(Test-Path -Path $($BaseSolutionDirectory)){
        Remove-Item -Recurse -Force $($BaseSolutionDirectory)
        WriteColour -Message "Removed the previous version located at $($BaseSolutionDirectory)." -Colour "Green"
    }
    else {
        WriteColour -Message "The previous version located at $($BaseSolutionDirectory) did not exist." -Colour "Green"
    }
    WriteColour -Message "Completed directory creation." -Colour "Green"
}

Export-ModuleMember -Function RemovePreviousSolution