<#
.SYNOPSIS
    Gets the region specific AMI ID of an AMI. 
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Region,

    [ValidateSet('AmazonLinux2')]
    $AMI = 'AmazonLinux2'
)
Process {
    #ignore this for now
    $amidescriptionfilter = switch ( $AMI ) {
        AmazonLinux2 { 'Amazon Linux 2 AMI 2.0.*HVM gp2' }
        Default { 'Amazon Linux 2 AMI 2.0.*HVM gp2'}
    }
    $amiSplat = @{
        Region = $Region
        Filter = @(
            @{Name = 'state';Values = 'available'},
            @{Name = 'owner-alias';Values = 'amazon'},
            @{Name="description"; Values=$amidescriptionfilter}
        )
    }
    $images = Get-EC2Image @amiSplat

    $image = $images | Sort-Object CreationDate -Descending | Select-Object -First 1

    return $image.ImageId
}