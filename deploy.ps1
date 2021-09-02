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
[CmdletBinding(SupportsShouldProcess , ConfirmImpact = 'High')]
param (
    [Parameter()]
    [string]
    [ValidateSet('Common','Development','Production')]
    $Environment = 'Common'
)
Begin {
    $env:DEPLOY_ENVIRONMENT = $Environment
}

Process {
    #check for proper dir structure things
    $modules = Get-ChildItem -Directory | Where-Object { Get-ChildItem $_ | Where-Object { $_.BaseName -match $Environment } }
    foreach ( $module in $modules ) {
        $stackfile = '{0}\stacks.yaml' -f $module.FullName
        $envfile = Get-ChildItem $module.FullName -Filter *.env -File | Where-Object { $_.BaseName -match "^$Environment" }
        if ( -not $envfile ) {
            throw "No environment file found for $Environment"
        }
        if (-not ( Test-Path $stackfile ) ) {
            throw "Stackfile not found"
        }
    }

    #let R Rip
        if ( $WhatIfPreference ) {
        Write-Warning 'Running Taxi Only. NO CHANGES WILL BE MADE TO ENVIRONMENT!!!'
        runway.exe taxi
    } 
    if( $PSCmdlet.ShouldProcess( $Environment, "Deploy to environment") ) {
        runway.exe deploy
    }
}