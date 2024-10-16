[CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$BearerToken,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
[string]$RepositoryName
    )
$authorisationHeader = "Authorization: Bearer $BearerToken"
$creationBody = '{"name": "' + $RepositoryName + '", "description":"This is your first repository","homepage":"https://github.com/astar-development/' 
$creationBody += $RepositoryName + '","private":false,"has_issues":true,"has_projects":true,"has_wiki":true,'
$creationBody +='"gitignore_template":"VisualStudio","license_template":"mit","delete_branch_on_merge":true}'
#curl -L -X POST -H "Accept: application/vnd.github+json" -H $authorisationHeader -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/orgs/astar-development/repos -d $creationBody

curl -L -X PUT -H "Accept: application/vnd.github+json" -H $authorisationHeader -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/astar-development/$RepositoryName/automated-security-fixes

$ruleSet = '{"name":"super cool ruleset","target":"branch","enforcement":"active","conditions":{"ref_name":{"include":["refs/heads/main"],"exclude":["refs/heads/dev*"]}},"rules":[{"type":"commit_author_email_pattern","parameters":{"operator":"contains","pattern":"github"}}]}'

curl -L -X POST -H "Accept: application/vnd.github+json" -H $authorisationHeader -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/astar-development/$RepositoryName/rulesets -d $ruleSet