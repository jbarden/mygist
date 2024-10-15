function ConfigureGit {
    git init --initial-branch=main
    git config --global gpg.program "c:/Program Files (x86)/GnuPG/bin/gpg.exe"
    git config --global user.signingkey AF697941C147E382
    git config --global user.name "Jason Barden"
    git config --global user.email "jason.barden@outlook.com"
    git config --global commit.gpgsign true
}

Export-ModuleMember -Function ConfigureGit