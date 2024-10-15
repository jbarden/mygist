function EndOutput {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the Start Time of the overall creation - this will be used to calculate the total process time.')]
        [string]$startTime
    )
    
    $endTime = Get-Date
    $duration = New-TimeSpan -Start ([datetime]$startTime) -End $endTime
    WriteColour -Message "Start time: $($startTime)." -Colour "DarkYellow"
    WriteColour -Message "End time: $($endTime)." -Colour "DarkYellow"
    WriteColour -Message "Total processing time: $($duration.TotalMinutes) minutes." -Colour "Green"    
}

Export-ModuleMember -Function EndOutput