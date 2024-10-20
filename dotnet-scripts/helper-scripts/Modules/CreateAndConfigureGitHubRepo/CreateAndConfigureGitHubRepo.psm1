function CreateAndConfigureGitHubRepo {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the bearer token to access GitHub with.')]
        [string]$BearerToken,
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the name of the repository to create.')]
        [string]$RepositoryName,
        [Parameter(Mandatory = $true, HelpMessage = 'Please specify the description for the repository.')]
        [string]$Description,
        [Parameter(Mandatory = $false, HelpMessage = 'Please specify the owner / organisation for the repository.')]
        [string]$Owner = "astar-development",
        [Parameter(Mandatory = $false, HelpMessage = 'Please specify the root directory to clone the repository to (if $clone is set to true).')]
        [string]$RootDirectory,
        [Parameter(Mandatory = $false, HelpMessage = 'Please specify whether to clone the repository. The default is false')]
        [bool]$clone = $false
    )
    
    $authorisationHeader = "Authorization: Bearer $BearerToken"
    $RepositoryName = $RepositoryName.Replace(".", "-").ToLower()
    $creationBody = '{"name": "' + $RepositoryName + '", "description":"' + $Description + '","homepage":"https://github.com/$Owner/$RepositoryName","private":false,"has_issues":true,"has_projects":true,"has_wiki":true,'
    $creationBody +='"gitignore_template":"VisualStudio","license_template":"mit","delete_branch_on_merge":true}'

    curl -L -X POST -H "Accept: application/vnd.github+json" -H $authorisationHeader -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/orgs/$Owner/repos -d $creationBody

    curl -L -X PUT -H "Accept: application/vnd.github+json" -H $authorisationHeader -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/$Owner/$RepositoryName/automated-security-fixes

    $rules = '"rules": [
        {
        "type": "deletion"
        },
        {
        "type": "non_fast_forward"
        },
        {
        "type": "pull_request",
        "parameters": {
            "required_approving_review_count": 1,
            "dismiss_stale_reviews_on_push": true,
            "require_code_owner_review": false,
            "require_last_push_approval": true,
            "required_review_thread_resolution": true
        }
        }
    ]'
    $ruleSet = '{"name":"protect the main branch","target":"branch","enforcement":"active","conditions":{"ref_name":{"include":["refs/heads/main"],"exclude":["refs/heads/dev*"]}},' + $rules + '}'

    curl -L -X POST -H "Accept: application/vnd.github+json" -H $authorisationHeader -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/$Owner/$RepositoryName/rulesets -d $ruleSet

    if($clone) {
        Set-Location "$RootDirectory\..\"
        git clone https://github.com/$Owner/$RepositoryName
        Set-Location $RootDirectory
        Write-Host "git checkout -b initial-creation"
        git checkout -b "initial-creation"
        
        git config --global gpg.program "c:/Program Files (x86)/GnuPG/bin/gpg.exe"
        git config --global user.signingkey AF697941C147E382
        git config --global user.name "Jason Barden"
        git config --global user.email "jason.barden@outlook.com"
        git config --global commit.gpgsign true
    }
}

Export-ModuleMember -Function CreateAndConfigureGitHubRepo