# PSC - a PowerShell Script Collection
A collection of useful "at least to me" PowerShell Scripts.

## Get-OUI
Takes a single argument of either a single MAC address or an array of MAC addresses and then queries an API for their OUI vendor information.

## Network_Discovery
A script to give you a rundown of the devices on your subnet, which including information regarding their: IP Addresses, Hostnames, Mac Addresses, NIC cards, Ports. I've listed a few things to be aware of below.
1. Only a single port may be tested as time currently
2. Results are output as a custom PS Object for further refinement
3. Script cannot yet take pipeline data from other cmdlets








