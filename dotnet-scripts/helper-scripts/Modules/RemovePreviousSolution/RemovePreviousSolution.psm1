function RemovePreviousSolution {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the root directory to remove the previous solution from.')]
        [string]$BaseSolutionDirectory
    )

    WriteColour -Message "Removing the previous version located at $($BaseSolutionDirectory)." -Colour "Magenta"
    if(Test-Path -Path $($BaseSolutionDirectory)){
        Remove-Item -Recurse -Force $($BaseSolutionDirectory)
        WriteColour -Message "Removed the previous version located at $($BaseSolutionDirectory)." -Colour "Green"
    }
    else {
        WriteColour -Message "The previous version located at $($BaseSolutionDirectory) did not exist, removal is therefore not relevant." -Colour "Green"
    }
}

Export-ModuleMember -Function RemovePreviousSolution