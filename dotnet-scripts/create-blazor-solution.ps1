#  .\Create-Blazor-Solution.ps1 -RootDirectory c:\repos -SolutionName AStar.ASPNet.Extensions

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the root directory to use to create the new solution.')]
    [string]$RootDirectory,
    [Parameter(Mandatory = $true, HelpMessage = 'Specify the solution name, this will be used to create the solution file and all associated projects.')]
    [string]$SolutionName,
    [Parameter(HelpMessage='Controls whether to run the update and NuGet restore. The default is $true to update all NuGet packages but this does add roughly 2 minutes.')]
    [bool]$UpdateNuget = $true,
    [Parameter(HelpMessage='Controls whether to redploy (i.e. remove all existing files) the template. The default is, for safety, $false.')]
    [bool]$Redeploy = $false,
    [Parameter(HelpMessage='Controls whether to launch the new solution. The default is, for the sake of speed, $false.')]
    [bool]$LaunchOnCompletion = $false
)

begin {
    $StartingFolder = Get-Location
    $SolutionFile = "$($SolutionName).sln"
    $SolutionNameAsPath = $SolutionName.Replace(".", "-").ToLower()
    $BaseSolutionDirectory = "$($RootDirectory)\$($SolutionNameAsPath)"
    $SolutionFileWithPath = "$($BaseSolutionDirectory)\$($SolutionFile)"
    $UIProjectName = "$($SolutionName).UI"
    $APIProjectName = "$($SolutionName).API"
    $DomainProjectName = "$($SolutionName).Domain"
    $InfrastructureProjectName = "$($SolutionName).Infrastructure"
    $startTime = Get-Date

    function WriteColour($colour) {
        process { Write-Host $_ -ForegroundColor $colour }
    }
}

process {
    if($Redeploy) {
        Write-Output "Removing the previous version located at $($BaseSolutionDirectory)." | WriteColour("DarkMagenta")
        remove-item $($BaseSolutionDirectory) -recurse -force
        Write-Output "Removed the previous version located at $($BaseSolutionDirectory)." | WriteColour("Green")
    }

    Write-Output "Starting directory creation." | WriteColour("DarkMagenta")
    mkdir "$($BaseSolutionDirectory)\src"
    mkdir "$($BaseSolutionDirectory)\src\ui"
    mkdir "$($BaseSolutionDirectory)\src\api"
    mkdir "$($BaseSolutionDirectory)\src\core"
    mkdir "$($BaseSolutionDirectory)\tests\unit"
    mkdir "$($BaseSolutionDirectory)\tests\integration"
    mkdir "$($BaseSolutionDirectory)\tests\acceptance"
    mkdir "$($BaseSolutionDirectory)\tests\architecture"
    Write-Output "Completed directory creation." | WriteColour("Green")
    
    Write-Output "Copying files." | WriteColour("DarkMagenta")
    xcopy .\.editorconfig $BaseSolutionDirectory /Y
    xcopy .\CodeMaid.config $BaseSolutionDirectory /Y
    xcopy .\.git* $BaseSolutionDirectory /Y
    Write-Output "Completed copying files." | WriteColour("Green")
    
    Write-Output "Creating the solution file." | WriteColour("DarkMagenta")
    dotnet new sln --name "$($SolutionName)" --output "$($BaseSolutionDirectory)"
    Write-Output "Creating the UI project." | WriteColour("DarkMagenta")
    dotnet new blazor --name "$($UIProjectName)" --output "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
    dotnet add "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)\$($UIProjectName).csproj" package --no-restore Blazor.Bootstrap --version "2.2.0"
    dotnet add "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)\$($UIProjectName).csproj" package --no-restore AStar.ASPNet.Extensions --version "0.2.0"
    dotnet add "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)\$($UIProjectName).csproj" package --no-restore AStar.CodeGenerators --version "0.2.0"
    Write-Output "Created the UI project." | WriteColour("Green")
    
    Write-Output "Creating the API project." | WriteColour("DarkMagenta")
    dotnet new webapi --name "$($APIProjectName)" --output "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"
    dotnet add "$($BaseSolutionDirectory)\src\api\$($APIProjectName)\$($APIProjectName).csproj" package --no-restore AStar.ASPNet.Extensions --version "0.2.0"
    dotnet add "$($BaseSolutionDirectory)\src\api\$($APIProjectName)\$($APIProjectName).csproj" package --no-restore AStar.CodeGenerators --version "0.2.0"
    Write-Output "Created the API project." | WriteColour("Green")
    
    Write-Output "Creating the Domain project." | WriteColour("DarkMagenta")
    dotnet new classlib --name "$($DomainProjectName)" --output "$($BaseSolutionDirectory)\src\core\$($DomainProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\src\core\$($DomainProjectName)"
    dotnet add "$($BaseSolutionDirectory)\src\api\$($APIProjectName)\$($APIProjectName).csproj" reference "$($BaseSolutionDirectory)\src\core\$($DomainProjectName)"
    Write-Output "Created the Domain project." | WriteColour("Green")
    
    Write-Output "Creating the Infrastructure project." | WriteColour("DarkMagenta")
    dotnet new classlib --name "$($InfrastructureProjectName)" --output "$($BaseSolutionDirectory)\src\core\$($InfrastructureProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\src\core\$($InfrastructureProjectName)"
    dotnet add "$($BaseSolutionDirectory)\src\api\$($APIProjectName)\$($APIProjectName).csproj" reference "$($BaseSolutionDirectory)\src\core\$($InfrastructureProjectName)"
    dotnet add "$($BaseSolutionDirectory)\src\core\$($InfrastructureProjectName)\$($InfrastructureProjectName).csproj" reference "$($BaseSolutionDirectory)\src\core\$($DomainProjectName)"
    Write-Output "Created the Infrastructure project." | WriteColour("Green")
    
    Write-Output "Creating the UI Unit Tests project." | WriteColour("DarkMagenta")
    dotnet new xunit --name "$($UIProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests"
    dotnet add "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests\$($UIProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
    dotnet add "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests\$($UIProjectName).Unit.Tests.csproj" reference "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($UIProjectName).Unit.Tests"
    Write-Output "Created the UI Unit Tests project." | WriteColour("Green")
    
    Write-Output "Creating the API Unit Tests project." | WriteColour("DarkMagenta")
    dotnet new xunit --name "$($APIProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests"
    dotnet add "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests\$($APIProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
    dotnet add "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests\$($APIProjectName).Unit.Tests.csproj" reference "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($APIProjectName).Unit.Tests"
    Write-Output "Created the API Unit Tests project." | WriteColour("Green")
    
    Write-Output "Creating the Domain Unit Tests project." | WriteColour("DarkMagenta")
    dotnet new xunit --name "$($DomainProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests"
    dotnet add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests\$($DomainProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
    dotnet add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests\$($DomainProjectName).Unit.Tests.csproj" reference "$($BaseSolutionDirectory)\src\core\$($DomainProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($DomainProjectName).Unit.Tests"
    Write-Output "Created the Domain Unit Tests project." | WriteColour("Green")
    
    Write-Output "Creating the Infrastructure Unit Tests project." | WriteColour("DarkMagenta")
    dotnet new xunit --name "$($InfrastructureProjectName).Unit.Tests" --output "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests"
    dotnet add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests\$($InfrastructureProjectName).Unit.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
    dotnet add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests\$($InfrastructureProjectName).Unit.Tests.csproj" reference "$($BaseSolutionDirectory)\src\core\$($InfrastructureProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\unit\$($InfrastructureProjectName).Unit.Tests"
    Write-Output "Created the Infrastructure Unit Tests project." | WriteColour("Green")
    
    Write-Output "Creating the UI Integration Tests project." | WriteColour("DarkMagenta")
    dotnet new xunit --name "$($UIProjectName).Integration.Tests" --output "$($BaseSolutionDirectory)\tests\integration\$($UIProjectName).Integration.Tests"
    dotnet add "$($BaseSolutionDirectory)\tests\integration\$($UIProjectName).Integration.Tests\$($UIProjectName).Integration.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
    dotnet add "$($BaseSolutionDirectory)\tests\integration\$($UIProjectName).Integration.Tests\$($UIProjectName).Integration.Tests.csproj" reference "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\integration\$($UIProjectName).Integration.Tests"
    Write-Output "Created the UI Integration Tests project." | WriteColour("Green")
    
    Write-Output "Creating the UI Acceptance Tests project." | WriteColour("DarkMagenta")
    dotnet new xunit --name "$($UIProjectName).Acceptance.Tests" --output "$($BaseSolutionDirectory)\tests\acceptance\$($UIProjectName).Acceptance.Tests"
    dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($UIProjectName).Acceptance.Tests\$($UIProjectName).Acceptance.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
    dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($UIProjectName).Acceptance.Tests\$($UIProjectName).Acceptance.Tests.csproj" reference "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\acceptance\$($UIProjectName).Acceptance.Tests"
    Write-Output "Created the UI Acceptance Tests project." | WriteColour("Green")
    
    Write-Output "Creating the API Acceptance Tests project." | WriteColour("DarkMagenta")
    dotnet new xunit --name "$($APIProjectName).Acceptance.Tests" --output "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests"
    dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests\$($APIProjectName).Acceptance.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
    dotnet add "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests\$($APIProjectName).Acceptance.Tests.csproj" reference "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\acceptance\$($APIProjectName).Acceptance.Tests"
    Write-Output "Created the API Acceptance Tests project." | WriteColour("Green")
    
    dotnet new xunit --name "$($APIProjectName).Integration.Tests" --output "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests"
    dotnet add "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests\$($APIProjectName).Integration.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
    dotnet add "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests\$($APIProjectName).Integration.Tests.csproj" reference "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\integration\$($APIProjectName).Integration.Tests"
    
    Write-Output "Creating the Architecture Tests project." | WriteColour("DarkMagenta")
    dotnet new xunit --name "$($SolutionName).Architecture.Tests" --output "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests"
    dotnet add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests\$($SolutionName).Architecture.Tests.csproj" package --no-restore FluentAssertions --version "6.12.0"
    dotnet add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests\$($SolutionName).Architecture.Tests.csproj" reference "$($BaseSolutionDirectory)\src\api\$($APIProjectName)"
    dotnet add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests\$($SolutionName).Architecture.Tests.csproj" reference "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
    dotnet add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests\$($SolutionName).Architecture.Tests.csproj" reference "$($BaseSolutionDirectory)\src\core\$($DomainProjectName)"
    dotnet add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests\$($SolutionName).Architecture.Tests.csproj" reference "$($BaseSolutionDirectory)\src\core\$($InfrastructureProjectName)"
    dotnet sln "$($SolutionFileWithPath)" add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests"
    dotnet add "$($BaseSolutionDirectory)\tests\architecture\$($SolutionName).Architecture.Tests\$($SolutionName).Architecture.Tests.csproj" package --no-restore TngTech.ArchUnitNET.xUnit --version "0.10.6"
    Write-Output "Created the Architecture Tests project." | WriteColour("Green")

    if($UpdateNuget){
        Set-Location "$($BaseSolutionDirectory)"
        
        dotnet restore "$($SolutionFileWithPath)"
        
        Write-Output "Starting project restores." | WriteColour("DarkMagenta")
        $regex = 'PackageReference Include="([^"]*)" Version="([^"]*)"'
        
        ForEach ($file in get-childitem . -recurse | Where-Object { $_.extension -like "*.csproj" }) {
            $packages = Get-Content $file.FullName |
            select-string -pattern $regex -AllMatches | 
            ForEach-Object { $_.Matches } | 
            ForEach-Object { $_.Groups[1].Value.ToString() } | 
            Sort-Object -Unique
            
            ForEach ($package in $packages) {
                Write-Output "Update project: $($file.FullName), package: $package." | WriteColour("magenta")
                $fullName = $file.FullName
                dotnet add $fullName package $package
                Write-Output "Updated project: $($file.FullName), package: $package." | WriteColour("Green")
            }
        }
    }

    & "$PSScriptRoot\add-blazor-bootstrap.ps1" -UIProjectFolder "$($BaseSolutionDirectory)\src\ui\$($UIProjectName)"
    & "$PSScriptRoot\update-ui-and-api-projects.ps1" -BaseDirectory "$($BaseSolutionDirectory)\src" -UIProjectPath $("$($BaseSolutionDirectory)\src\ui\$($UIProjectName)") -APIProjectPath $("$($BaseSolutionDirectory)\src\api\$($APIProjectName)")
}

end {
    Set-Location "$($StartingFolder)"
    $endTime = Get-Date
    $duration = New-TimeSpan -Start $startTime -End $endTime
    Write-Output "Start time: $($startTime)." | WriteColour("DarkYellow")
    Write-Output "End time: $($endTime)." | WriteColour("DarkYellow")
    Write-Output "Total processing time: $($duration.TotalMinutes) minutes." | WriteColour("Green")
    if($LaunchOnCompletion) {
        & 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe' $SolutionFileWithPath
    }
}
