function GitHubPipelines {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the root directory to use when creating the new solution.')]
        [string]$BaseSolutionDirectory,
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the Solution Name as Path.')]
        [string]$SolutionNameAsPath,
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the Solution Name.')]
        [string]$SolutionName
    )

    $filePath = "$($BaseSolutionDirectory)\.github\workflows\dotnet.yml"
        $fileContent = Get-Content -Path $filePath -Raw
        $fileContent = $fileContent.Replace("{sonar-project-name}", $SolutionNameAsPath)
        $fileContent = $fileContent.Replace("{project-name}", $SolutionName)
        $fileContent | Set-Content -Path $filePath

    WriteColour -Message "Completed GitHub pipeline updates." -Colour "Green"
}

Export-ModuleMember -Function GitHubPipelines