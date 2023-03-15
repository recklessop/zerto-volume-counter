# zerto-volume-counter

This python script counts the volumes in the /volumes API output json to give a total per VRA (including it's helper VRA volumes)

Use the ZVM swagger interface to get the volumes API json data. 

Save the data into a file like volumes.json

then run the parser

python3 parser.py jsonfile.json

Expected output is:

Total Volumes per VRA (Mirror + journal + scratch) \n
vra_volumes{OwningVRA="192.168.50.52"} : 13\n
vra_volumes{OwningVRA="192.168.50.51"} : 14
