function WriteColour {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the message to display.')]
        [string]$Message,
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the colour to display the message in.')]
        [string]$Colour
    )
    Write-Host $Message -ForegroundColor $Colour    
}

Export-ModuleMember -Function WriteColour