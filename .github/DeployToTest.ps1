Param(
    [Hashtable]$parameters = @{
        "type"                 = "CD"; # Type of delivery (CD or Release)
        "apps"                 = $null; # Path to folder containing apps to deploy
        "EnvironmentType"      = "SaaS"; # Environment type
        "EnvironmentName"      = $null; # Environment name
        "Branches"             = $null; # Branches which should deploy to this environment (from settings)
        "AuthContext"          = '{}'; # AuthContext in a compressed Json structure
        "BranchesFromPolicy"   = $null; # Branches which should deploy to this environment (from GitHub environments)
        "Projects"             = "."; # Projects to deploy to this environment
        "ContinuousDeployment" = $false; # Is this environment setup for continuous deployment?
        "runs-on"              = "windows-latest"; # GitHub runner to be used to run the deployment script
    }
)

$ErrorActionPreference = "Stop"
$parameters | ConvertTo-Json -Depth 99 | Out-Host

$tempPath = Join-Path ([System.IO.Path]::GetTempPath()) ([GUID]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tempPath | Out-Null

Copy-AppFilesToFolder -appFiles $parameters.apps -folder $tempPath | Out-Null
$appsList = Get-ChildItem -Path $tempPath -Filter *.app
if (-not $appsList -or $appsList.Count -eq 0) {
    Write-Host "::error::No apps to publish found."
    exit 1
}

Write-Host "Apps:"
$appsList | ForEach-Object { Write-Host "- $($_.Name)" }

