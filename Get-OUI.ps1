





 # [Single parameter] either a MAC address as a string or an array of MAC Addresses

 function global:Get-OUI{
    
    [CmdletBinding()]
    param ($MacAddress
    )


    $count = 0
    $MacAddressObjects = New-Object System.Collections.ArrayList
    if ($Param1 -is [string]){
    $URI = "https://api.macvendors.com/" + $MacAddress
    $Vendor = Invoke-RestMethod -Uri $URI
    $temp = New-Object System.Object
    $temp | Add-Member -MemberType NoteProperty -Name "Index" -Value $count
    $temp | Add-Member -MemberType NoteProperty -Name "MAC Address" -Value $Vendor
    $MacAddressObjects.add($temp) | Out-Null
    }
    elseif($MacAddress -is [array]){
        
        Foreach($item in $MacAddress)  {
        $URI = "https://api.macvendors.com/" + $item
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
Get-OUI