<#
.SYNOPSIS
    Powershell parser for openfile.exe
.DESCRIPTION
    Powershell parser for openfile.exe
.PARAMETER Server
    Servername to user openfile.exe
.EXAMPLE
    C:\PS> 
    .\Get-Openfile.ps1 -Server <servername>
.EXAMPLE
    C:\PS> 
    .\Get-Openfile.ps1 -Server <servername> | Where-Object {$_.OpenFile -like "C:\path\to\check"}
.NOTES
    Author: Christoph Haug
    Date:   September 6, 2017
    First implementation
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True, ValueFromPipeline=$False, ValueFromPipelineByPropertyName=$False, HelpMessage='Servername')]
    [String] 
    $Server = "fileserver"
 )
 $data=openfiles.exe /query /s $Server /fo TABLE /v
 $data=$data[3..($data.Length -1)]
 FOREACH ($line in $data){
    $mData=([regex]::Match($line,"([^\s]+)\s([^\s]+)\s*([^\s]+)\s*([^\s]+)\s*([^\s]+)\s*([^\s]+)\s*(.*)"))
    $properties=@{
        Hostname = $mData.Groups[1]
        ID = $mData.Groups[2]
        AccessBy = $mData.Groups[3]
        Type = $mData.Groups[4]
        Locks = $mData.Groups[5]
        OpenMode = $mData.Groups[6]
        OpenFile = $mData.Groups[7]
    }
    New-Object -TypeName PSObject -Property $properties
 }
 
