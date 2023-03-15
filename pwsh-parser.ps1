# PowerShell equivalent of "python3 parser.json <json filename>"
Param(
    [Parameter(Mandatory=$true)]
    [string]$Filename
)

# Load the JSON data from the specified file
$data = Get-Content $Filename | ConvertFrom-Json

# Initialize a dictionary to store the volume metrics
$metricsDictionary = @{}

# Iterate over each volume in the JSON data
foreach ($volume in $data) {
    # Check if the volume's owning VM starts with "Z-VRA"
    if ($volume.OwningVm.Name.StartsWith("Z-VRA")) {
        # Extract the VRA number from the VM name
        $vra = $volume.OwningVm.Name.Split("-")[2]

        # Construct the metric key for this VRA
        $metrickey = "vra_volumes{OwningVRA=`"$vra`"}"

        # Increment the volume count for this VRA in the dictionary
        if ($metricsDictionary.ContainsKey($metrickey)) {
            $metricsDictionary[$metrickey]++
        }
        else {
            $metricsDictionary[$metrickey] = 1
        }
    }
}

# Print the total number of volumes per VRA
Write-Host "Total Volumes per VRA (Mirror + journal + scratch)"
foreach ($key in $metricsDictionary.Keys) {
    Write-Host "$key : $($metricsDictionary[$key])"
}
