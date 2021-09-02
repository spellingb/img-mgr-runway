[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Region
)
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
            Write-Warning "SSH key Imported into region $region"
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
    return $keyPair
    #endregion KeyPair
