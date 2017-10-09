<#
.SYNOPSIS
    Add ADLastLogon Attribute to Get-ADUser
.DESCRIPTION
    Add a Property to Microsoft.ActiveDirectory.Management.ADUser Object. This Attribute display the user last logon date. 
    Last logon date is stored on each ActiveDirectory Server and is not syncing.
.PARAMETER Identity
    Identity of User. Example samaccountname
.PARAMETER Filter
    Specifies a query string that retrieves Active Directory objects
.EXAMPLE
    C:\PS> 
    .\Get-ADUserLastLogon.ps1 -Identity username
.EXAMPLE
    C:\PS> 
    .\Get-ADUserLastLogon.ps1 -Filter *
.NOTES
    Author: Christoph Haug
    Date:   October 09, 2017
    First implementation
#>
[CmdletBinding(DefaultParameterSetname='ByIdentity')]
Param(
    [Parameter(Mandatory=$True, ValueFromPipeline=$False, ValueFromPipelineByPropertyName=$False, HelpMessage='username',ParameterSetName="ByFilter")]
    [String] 
    $Filter = "",
    [Parameter(Mandatory=$True, ValueFromPipeline=$False, ValueFromPipelineByPropertyName=$False, HelpMessage='username',ParameterSetName="ByIdentity")]
    [String] 
    $Identity = ""
)
function Get-ADUserLastLogon()
{
    [cmdletbinding()]
    Param
    (
     [parameter(Mandatory,ValueFromPipeline)]
     [Microsoft.ActiveDirectory.Management.ADUser] $adUser
    )
    
    begin{}
    process{
            $dcs = Get-ADDomainController -Filter {Name -like "*"}
            $time = 0
            foreach($dc in $dcs)
            { 
                $hostname = $dc.HostName
                $user = $adUser | Get-ADObject -Properties lastLogon 
                if($user.LastLogon -gt $time) 
                {
                    $time = $user.LastLogon
                }
            }
            $dt = [DateTime]::FromFileTime($time)
            $adUser | Add-Member -NotePropertyName ADLastLogon -NotePropertyValue $dt -Force
            return $adUser
    }
    
    end{}
  
  }
  if($Identity -ne $null -and $Identity -ne ''){
    get-aduser $Identity | Get-ADUserLastLogon
  }
  if($Filter -ne $null -and $Filter -ne ''){
    get-aduser -Filter $Filter | Get-ADUserLastLogon
  }
