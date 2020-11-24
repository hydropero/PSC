
function Get-OUI{
    
<#
.SYNOPSIS

Perform a look of a MAC Address to find the OUI Vendor

.DESCRIPTION

Takes a MAC address in the form of a string or an array of strings
and then uses an a free API to returns the associated OUI Vendor

.SYNTAX
   Get-OUI [System.String] [System.Array]

   Get-OUI "08-00-27-fc-7a-c1"

   Get-OUI @("08-00-27-fc-7a-c1", "04-d4-c4-c6-e8-98", "f8-e4-e3-49-2c-f3")

   Get-OUI $array_of_mac_addresses


.INPUTS

None. You cannot pipe objects to Add-Extension.

.OUTPUTS

System.String. Add-Extension returns a string with the extension
or file name.

.EXAMPLE

PS> extension -name "File"
File.txt

.EXAMPLE

PS> extension -name "File" -extension "doc"
File.doc

.EXAMPLE

PS> extension "File" "doc"
File.doc

.LINK

http://www.fabrikam.com/extension.html

.LINK

Set-Item
#>
    # [Single parameter] either a MAC address as a string or an array of MAC Addresses
    $Param1 = $args[0]
    $count = 0
    $MacAddressObjects = New-Object System.Collections.ArrayList

    if ($Param1 -is [string]){
    $URI = "https://api.macvendors.com/" + $Param1
    $Vendor = Invoke-RestMethod -Uri $URI
    $temp = New-Object System.Object
    $temp | Add-Member -MemberType NoteProperty -Name "Index" -Value $count
    $temp | Add-Member -MemberType NoteProperty -Name "MAC Address" -Value $Vendor
    $MacAddressObjects.add($temp) | Out-Null
    echo 'string'
    }

    elseif($param1 -is [array]){
        
        Foreach($item in $Param1)  {
        $URI = "https://api.macvendors.com/" + $Param1
        $Vendor = Invoke-RestMethod -Uri $URI
        Start-Sleep 1
        $temp = New-Object System.Object
        $temp | Add-Member -MemberType NoteProperty -Name "Index" -Value $count
        $temp | Add-Member -MemberType NoteProperty -Name "MAC Address" -Value $Vendor
        $MacAddressObjects.add($temp) | Out-Null 
            $count++
        }
    }

    $MacAddressObjects
}

Export-ModuleMember -Function Get-OUI
