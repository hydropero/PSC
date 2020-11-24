

function global:Net_Discovery {

[CmdletBinding()]
param (
    [string]$Port
)

# This selects the only NIC device that is configured with default gateway
$nic_configuration = gwmi -computer .  -class "win32_networkadapterconfiguration" | Where-Object {$_.defaultIPGateway -ne $null}


# Removes whitespace from the previously captured IP address
$IPv4 = $nic_configuration.IPAddress  | Select-Object -Index 0


# Removes whitespace from the previously captured Subnet mask
$SubnetMask = $nic_configuration.IPSubnet | Select-Object -Index 0


# Counts the number of octets set to 255 in a subnet mask
$num_of_octets = ([regex]::Matches($SubnetMask, "255" )).count


# this cuts away the host portion of the IP address in preparation to change to the broadcast address for the LAN
$result = ($IPv4.Split(".",$num_of_octets + 1) | Select-Object -First 3) -join "."

# checks how much of the IP address is left - The network portion of the address
$count_of_periods = ([regex]::Matches($result, "\." )).count


# This adds a max octet as many times as necessary to create your broadcast address
while ( $count_of_periods -ne 3)
{
    $result = $result + ".255"
    $count_of_periods = ([regex]::Matches($result, "\." )).count
}


# Creates background process that pings the newly created broadcast address to populate arp with device IP's 
Start-Job -ScriptBlock { ping $result -n 15 | Out-Null }  | Out-Null
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "        Pinging Broadcast Address to populate ARP Table!"
Write-Host ""

# Function that renders small animation informing user that things are in progress
function ProcessingAnimation($scriptBlock) {
    $cursorTop = [Console]::CursorTop
    try {
        [Console]::CursorVisible = $false
        
        $counter = 0
        $frames = '|', '/', '-', '\' 
        $jobName = Start-Job -ScriptBlock { Start-Sleep 20 }
    
        while($jobName.JobStateInfo.State -eq "Running") {
            $frame = $frames[$counter % $frames.Length]
            
            Write-Host "$frame     $frame     $frame     $frame     $frame     $frame     $frame     $frame     $frame     $frame     $frame"
            [Console]::SetCursorPosition(0, $cursorTop)
            
            $counter += 1
            Start-Sleep -Milliseconds 125
        }
        
        # Only needed if you use a multiline frames
        Write-Host ($frames[0] -replace '[^\s+]', ' ')
    }
    finally {
        [Console]::SetCursorPosition(0, $cursorTop)
        [Console]::CursorVisible = $true
    }
}

# Calling animation function
ProcessingAnimation { Start-Sleep 5 }

Clear-Host

# pulls only dynamically aquired address from the ARP command
$dev_on_network = (arp /a /n $IPv4 | Select-String -Pattern 'dynamic')


# Creates array of IP Addresses and trims away unneccessary white space
$array_Of_Ip = ($dev_on_network -split '\r?\n').Trim()
$My_mac = $nic_configuration | Select-Object -Property 'MACAddress' | ft -HideTableHeaders | Out-string
$My_mac = $My_mac.Trim()
$array_Of_Ip += "$IPv4 $My_mac"


Write-Host `n`n
Write-Host -ForegroundColor Yellow "----------------------------------------------------------"

$Output_IP_array = @()
$Output_MAC_array = @()
$Output_Host_array = @()
$Output_OUI_array = @()
$Output_Port_array = @()
$Output_array = @()
$counter = 0
# Cycles through array of IP's
ForEach ($item in $array_Of_Ip) {

    $temp = $item.Substring(0, $item.IndexOf(' '))
    # this adds IP addresses to the array
    $Output_IP_Array += $temp
    

    $mac_address = $($item -replace '\s+', ' ').split()[1]
    $Output_MAC_array += $mac_address
    Write-Host -ForegroundColor Green "MAC Address: $mac_address"
    Write-Host -ForegroundColor Green "IP Address: $temp"
    
    try {
        # Runs DNS resolve on each IP address in the array    
    $Dev_Name = (Resolve-DnsName $temp -ErrorAction "Stop" | Select-Object -Property 'NameHost' | Format-Table -HideTableHeaders) | Out-String
    $Dev_Name = $Dev_Name.Trim()
    Write-Host -ForegroundColor Green "Hostname: $Dev_Name"
    $Output_Host_array += $Dev_Name
    Start-Sleep 1
    }
    catch {
        Write-Host -NoNewline -ForegroundColor Green "Hostname: "
        Write-Host -ForegroundColor Red "Unavailable"
        $Output_Host_array += "Unavailable"
    }

    try{
    $url_uri = "https://api.macvendors.com/" + $mac_address
    $vendor = Invoke-RestMethod -Uri $url_uri -ErrorAction "Stop"
    $Output_OUI_array += $vendor
    Write-Host -ForegroundColor Green "OUI Vendor: $vendor"
    Write-Host ""
    Write-Host -ForegroundColor Yellow "----------------------------------------------------------"

    }

    catch{
    Write-Host -NoNewline -ForegroundColor Green "OUI Vendor: "
    Write-Host -ForegroundColor Red "Unavailable"
    $Output_OUI_array += "Unavailable"
    Write-Host ""
    Write-Host -ForegroundColor Yellow "----------------------------------------------------------"
    }
    if ($port) {

    try{
    $socket = new-object -ErrorAction Stop System.Net.Sockets.TcpClient($Output_Host_array[$counter], $port) 
    

    If($socket.Connected){ 
    $Output_Port_array += "Open"
    $socket.Close() }
    }
    catch {
    $Output_Port_array += "Closed" 
    }
    }
    $counter += 1
  }




Clear-Host



 
$count = 0


$MyNetworkObjects = New-Object System.Collections.ArrayList



Foreach($item in $Output_IP_array)  {
        $temp = New-Object System.Object
        $temp | Add-Member -MemberType NoteProperty -Name "IP Address" -Value $Output_IP_array[$count]
        $temp | Add-Member -MemberType NoteProperty -Name "MAC Address" -Value $Output_MAC_array[$count]
        $temp | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $Output_Host_array[$count]
        $temp | Add-Member -MemberType NoteProperty -Name "OUI Vendor" -Value $Output_OUI_array[$count]
        if($port) {
        $temp | Add-Member -MemberType NoteProperty -Name "Port $port" -Value $Output_Port_array[$count]
        }
        $MyNetworkObjects.add($temp) | Out-Null
        $count = $count + 1 
        }
    



$MyNetworkObjects
}


Net_Discovery