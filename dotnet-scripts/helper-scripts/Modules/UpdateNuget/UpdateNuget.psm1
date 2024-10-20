function UpdateNuget {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the root directory to use to create the new solution.')]
        [string]$BaseSolutionDirectory
    )

    dotnet restore "$($SolutionFileWithPath)"
            
    WriteColour -Message "Starting solution restores." -Colour "Magenta"
    $regex = 'PackageReference Include="([^"]*)" Version="([^"]*)"'
            
    ForEach ($file in get-childitem . -recurse | Where-Object { $_.extension -like "*.csproj" }) {
        $packages = Get-Content $file.FullName |
        select-string -pattern $regex -AllMatches | 
        ForEach-Object { $_.Matches } | 
        ForEach-Object { $_.Groups[1].Value.ToString() } | 
        Sort-Object -Unique
                
        ForEach ($package in $packages) {
            WriteColour -Message "Update project: $($file.FullName), package: $package." -Colour "Magenta"
            $fullName = $file.FullName
            dotnet add $fullName package $package
            WriteColour -Message "Updated project: $($file.FullName), package: $package." -Colour "Green"
        }
    }
    WriteColour -Message "Completed solution restores." -Colour "Green"
}

Export-ModuleMember -Function UpdateNuget