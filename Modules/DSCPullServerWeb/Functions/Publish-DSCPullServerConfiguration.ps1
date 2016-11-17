
<#
    .SYNOPSIS
    Publish a MOF configuration to a DSC Pull Server.

    .DESCRIPTION
    The Publish-DSCPullServerConfiguration cmdlet uses the Invoke-RestMethod to
    upload the MOF configuration to the DSC Pull Server. The DSC Pull Server Web
    API must be deployed on the target DSC Pull Server.

    .INPUTS
    None.

    .OUTPUTS
    DSCPullServerWeb.Configuration.

    .EXAMPLE
    PS C:\> Publish-DSCPullServerConfiguration -Uri 'http://localhost:8081/api' -Name 'Demo' -Path '.\Demo.mof'
    Publish the demo MOF configuration to the DSC Pull Server.

    .EXAMPLE
    PS C:\> Publish-DSCPullServerConfiguration -Uri 'http://localhost:8081/api' -Name 'Demo' -Path '.\Demo.mof' -Credential 'DOMAIN\user'
    Invoke the cmdlet with alternative credentials to return publish a demo MOF
    configuration.

    .NOTES
    Author     : Claudio Spizzi
    License    : MIT License

    .LINK
    https://github.com/claudiospizzi/DSCPullServerWeb
#>

function Publish-DSCPullServerConfiguration
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    param
    (
        # Base uri to the DSC Pull Server including the relative '/api' path.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        # The name for the configuration.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # The local path if the MOF configuration file.
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_})]
        [System.String]
        $Path,

        # Optionally specify credentials for the request.
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    # Use splatting to prepare the parameters.
    $RestMethodParam = @{
        Method = 'Put'
        Uri    = "$Uri/configurations/$Name"
        InFile = $Path
    }

    # Depending on the credential input, add the default or specfic credentials.
    if ($null -eq $Credential)
    {
        $RestMethodParam.UseDefaultCredentials = $true
    }
    else
    {
        $RestMethodParam.Credential = $Credential
    }

    $configuration = Invoke-RestMethod @RestMethodParam

    $configuration.PSTypeNames.Insert(0, 'DSCPullServerWeb.Configuration')

    Write-Output $configuration
}