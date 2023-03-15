# python3 parser.json <json filename>
import json, sys

filename = sys.argv[1]

with open(filename, 'r') as f:
    data = json.load(f)

metricsDictionary = {}

for volume in data :
    if volume['OwningVm']['Name'].startswith("Z-VRA"):
        vra = (volume['OwningVm']['Name']).split("-")[2]
        metrickey = "vra_volumes{OwningVRA=\"" + vra + "\"}"
        if (metrickey in metricsDictionary):
            metricsDictionary[metrickey] = metricsDictionary[metrickey] + 1
        else:
            metricsDictionary[metrickey] = 1

print ("Total Volumes per VRA (Mirror + journal + scratch)")
for key in metricsDictionary:
    print(key + " : " + str(metricsDictionary[key]) ) 
