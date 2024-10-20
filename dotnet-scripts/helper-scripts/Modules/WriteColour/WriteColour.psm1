function WriteColour {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the message to display.')]
        [string]$Message,
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the colour to display the message in.')]
        [string]$Colour,
        [Parameter(HelpMessage='Controls whether to add the timestamp at the beginning of the message. The default is $true.')]
        [bool]$AddTimeStamp = $true
    )
    if($AddTimeStamp){
        $Message = "$(Get-Date) $($Message)"
    }
    Write-Host $Message -ForegroundColor $Colour    
}

Export-ModuleMember -Function WriteColour