# zerto-volume-counter

This python script counts the volumes in the /volumes API output json to give a total per VRA (including it's helper VRA volumes)

Use the ZVM swagger interface to get the volumes API json data. 

Save the data into a file like volumes.json

then run the parser

*Python3 Version:*

python3 parser.py jsonfile.json

*PowerShell Version*

pwsh ./volumes-per-vra.ps1 ./volumes.json

Expected output is:

Total Volumes per VRA (Mirror + journal + scratch)

vra_volumes{OwningVRA="192.168.50.52"} : 13

vra_volumes{OwningVRA="192.168.50.51"} : 14
