function WriteColour {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
        [string]$Message,
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the solution name, this will be used to create the solution file and all associated projects.')]
        [string]$Colour
    )
    Write-Host $Message -ForegroundColor $Colour    
}

Export-ModuleMember -Function WriteColour