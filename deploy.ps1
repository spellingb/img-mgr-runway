<#
.SYNOPSIS
    Wrapper script for deploying runway across environment.
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> .\deploy.ps1 -Environment Common
    Deploys the common environment stack.
.EXAMPLE
    PS C:\> .\deploy.ps1 -Environment Development
    Deploys the development environment stack.

.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    [ValidateSet('Common','Development','Production')]
    $Environment = 'Common',

    [switch]
    $DryRun
)

Process {
    $modules = Get-ChildItem -Directory
    $stackfile = '{0}\stacks.yaml' -f $modules[1].FullName
    $envfile = Get-ChildItem $modules[1].FullName -Filter *.env -File | Where-Object { $_.BaseName -match "^$Environment" }
    if ( -not $envfile ) {
        throw "No environment file found for $Environment"
    }

    if (-not ( Test-Path $stackfile ) ) {
        throw "Stackfile not found"
    }

    $env:DEPLOY_ENVIRONMENT = $Environment
    if ( $DryRun ) {
        runway.exe plan
    } else {
        runway.exe deploy
    }
}