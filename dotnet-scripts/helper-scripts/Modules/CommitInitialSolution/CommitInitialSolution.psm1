function CommitInitialSolution {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the BaseSolutionDirectory.')]
        [string]$BaseSolutionDirectory,
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the SolutionNameAsPath.')]
        [string]$SolutionNameAsPath,
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the SolutionName.')]
        [string]$SolutionName ,
        [Parameter(Mandatory = $false, HelpMessage = 'Specify the Owner.')]
        [string]$Owner
    )

        $gitBranch = "initial-creation"
        GitHubPipelines -BaseSolutionDirectory $BaseSolutionDirectory -SolutionNameAsPath $SolutionNameAsPath -SolutionName $SolutionName
        git add .
        git commit -m "Initial commit"
        git push --set-upstream origin $gitBranch

        $prBody = '{"title":"Initial solution creation","body":"Initial solution creation","head":"'+$Owner+':'+$gitBranch+'","base":"main"}'
        $response = (curl -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $BearerToken" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/$Owner/$SolutionNameAsPath/pulls -d $prBody) | ConvertFrom-Json

        $prUrl = "https://api.github.com/repos/$Owner/$SolutionNameAsPath/pulls/$($response.number)/requested_reviewers"
        curl -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $BearerToken" -H "X-GitHub-Api-Version: 2022-11-28" $prUrl -d '{"reviewers":["jaybarden1"]}'
}

Export-ModuleMember -Function CommitInitialSolution