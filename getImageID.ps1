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

    [ValidateSet('AmazonLinux2','Ubuntu20','Windows2019')]
    $AMI
)
Process {
    $amiSplat = @{
        Region = $Region
        Filter = @(
            @{
                Name = 'state';
                Values = 'available'
            },
            @{
                Name = 'architecture'
                Values = 'x86_64'
            }
        )
    }
    #ignore this for now
    switch ( $AMI ) {
        AmazonLinux2 { 
            $amiSplat.Filter += @{Name = 'owner-id';Values = '137112412989'}
            $amiSplat.Filter += @{Name="description"; Values='Amazon Linux 2 AMI 2.0.*HVM gp2'}
             }
        Ubuntu20 {
            $amiSplat.Filter += @{Name = 'owner-id';Values = '099720109477'}
            $amiSplat.Filter += @{Name='description'; Values='Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on*'}
        }
        Windows2019 {
            $amiSplat.Filter += @{Name = 'name';Values= 'Windows_Server-2019-English-Full-Base-*'}
            $amiSplat.Filter += @{Name = 'owner-id';Values = '801119661308'}
        }
        Default { return 'Specify an OS Bro[|Bro-ette]!'}
    }
    $images = Get-EC2Image @amiSplat

    $image = $images | Sort-Object CreationDate -Descending | Select-Object -First 1

    $image | select Name,Description,ImageId,CreationDate,OwnerId
}