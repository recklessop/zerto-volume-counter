Param(
    [Parameter(Mandatory=$true)]
    [string]$zvm,
    [Parameter(Mandatory=$true)]
    [string]$Username,
    [Parameter(Mandatory=$true)]
    [string]$Password
)

$strZVMIP = $zvm
$strZVMPort = "9669"
$strZVMUser = $Username
$strZVMPwd = $Password
## Perform authentication so that Zerto APIs can run. Return a session identifier that needs to be inserted in the header for subsequent requests.
function getxZertoSession ($userName, $password){
  $baseURL = "https://" + $strZVMIP + ":"+$strZVMPort
  $xZertoSessionURL = $baseURL +"/v1/session/add"
  $authInfo = ("{0}:{1}" -f $userName,$password)
  $authInfo = [System.Text.Encoding]::UTF8.GetBytes($authInfo)
  $authInfo = [System.Convert]::ToBase64String($authInfo)
  $headers = @{Authorization=("Basic {0}" -f $authInfo)}
  $contentType = "application/json"
  $xZertoSessionResponse = Invoke-WebRequest -Uri $xZertoSessionURL -Headers $headers -Method POST -Body $body -ContentType $contentType
    #$xZertoSessionResponse = Invoke-WebRequest -Uri $xZertoSessionURL -Headers $headers -Body $body -Method POST
    return $xZertoSessionResponse.headers.get_item("x-zerto-session")
}
#Extract x-zerto-session from the response, and add it to the actual API:
$xZertoSession = getxZertoSession $strZVMUser $strZVMPwd
$zertoSessionHeader = @{"x-zerto-session"=$xZertoSession}

# Make a GET request to the API endpoint and convert the response to JSON
$data = Invoke-RestMethod -Uri "https://$zvm/v1/volumes" -Method Get -SkipCertificateCheck -Headers $zertoSessionHeader

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
