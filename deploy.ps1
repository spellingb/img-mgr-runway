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

    #region Define KeyPair
    $keySplat = @{
        Region = $Region
        KeyName = 'MyVPCLab-KeyPair'
    }
    $priKey = "$home\.ssh\id_rsa"
    $pubKey = "$home\.ssh\id_rsa.pub"
    try {
        $keyPair = Get-EC2KeyPair @keySplat -ErrorAction Stop
    }
    catch {
        if ( ( Test-Path $priKey ) -and ( Test-Path $pubKey ) ) {
            $keySplat['PublicKey'] = [io.file]::ReadAllText( $pubKey )
            $keyPair = Import-EC2KeyPair @keySplat
            Write-Warning "SSH key Imported:"
        } else {
            #to-do:
            # find a way to match md5 of uploaded key to what is on localmachine
            # and only create new key if checksums do not match
            $keySplat['KeyName']
            $keyPair = New-EC2KeyPair @keySplat
            Write-Warning 'New Key Created:'
            $keyPair.KeyMaterial | Out-File -Encoding ascii -FilePath "$home\.ssh\MyVPCLab-KeyPair" -Force
        }
    }
    finally {
        Write-Verbose "$($keyPair|Out-String)" -Verbose
    }
    #endregion KeyPair


    #let R Rip
    $env:DEPLOY_ENVIRONMENT = $Environment
    if ( $DryRun ) {
        runway.exe plan
    } else {
        runway.exe deploy
    }
}