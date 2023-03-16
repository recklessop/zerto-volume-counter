Param(
    [Parameter(Mandatory=$true)]
    [string]$zvm,
    [Parameter(Mandatory=$true)]
    [string]$Username,
    [Parameter(Mandatory=$true)]
    [string]$Password
)

# Create a hashtable with the credentials to send to Keycloak
$creds = @{
    grant_type = "password"
    client_id = "zerto-client"
    username = $Username
    password = $Password
}

# Send a POST request to Keycloak to obtain a JWT token
$response = Invoke-RestMethod -Uri "https://$zvm/auth/realms/zerto/protocol/openid-connect/token" -Method Post -Body $creds -SkipCertificateCheck

# Get the access token from the response
$jwtToken = $response.access_token

# Set the JWT token header
$headers = @{
    Authorization = "Bearer $jwtToken"
}

# Make a GET request to the API endpoint and convert the response to JSON
$data = Invoke-RestMethod -Uri "https://$zvm/v1/volumes" -Method Get -Headers $headers -SkipCertificateCheck

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
