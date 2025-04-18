# Script originally created by Josh Makador
# Slightly modified/reused here for educational purposes, adapted for Linux PowerShell.
# This version monitors /var/log/auth.log for SSH failed password events, extracts geolocation info,
# and logs the results to an output file.

# Get API key from https://ipgeolocation.io/
$API_KEY      = "45eb50693323472f9531f66fa7c1861c"

# Define the output logfile name and path (saved in your home directory)
$LOGFILE_NAME = "failed_rdp.log"
$LOGFILE_PATH = "$HOME/$LOGFILE_NAME"

# Get the local hostname (used as the destination host in our log)
$destinationHost = hostname

# If the log file doesn't exist, create it.
if (-Not (Test-Path $LOGFILE_PATH)) {
    New-Item -ItemType File -Path $LOGFILE_PATH | Out-Null
    Write-Host "Created log file at $LOGFILE_PATH"
}

# Define a regular expression to match a failed SSH login event.
# Typical auth.log line may look like:
# "Apr 12 17:17:45 hostname sshd[12345]: Failed password for invalid user admin from 192.168.1.10 port 12345 ssh2"
# This regex extracts:
#   - timestamp (e.g., "Apr 12 17:17:45")
#   - username (after "Failed password for" which may optionally be preceded by "invalid user ")
#   - sourceIp (the IP address after "from")
$regex = '^(?<timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:[+-]\d{2}:\d{2})?)\s+\S+\s+sshd\[\d+\]:\s+Failed password for (?:invalid user\s+)?(?<username>\S+)\s+from\s+(?<sourceIp>\d+\.\d+\.\d+\.\d+)'

# Monitor /var/log/auth.log for new lines. Tail 0 ensures only new lines are processed.
Get-Content -Path "/var/log/auth.log" -Tail 0 -Wait | ForEach-Object {
    $line = $_

    # Check if the line contains "Failed password"
    if ($line -match "Failed password") {
        # Try to match the regex to extract fields
        $match = [regex]::Match($line, $regex)
        if ($match.Success) {
            # Extracted fields
            $rawTimestamp = $match.Groups["timestamp"].Value
            $username = $match.Groups["username"].Value
            $sourceIp = $match.Groups["sourceIp"].Value

            # Because the auth.log timestamp lacks a year, append the current year.
            $currentYear = (Get-Date).Year
            $timestamp = "$currentYear $rawTimestamp"

            # Pause to avoid API rate limiting.
            Start-Sleep -Seconds 1

            # Call the geolocation API to get location data for the source IP.
            $API_ENDPOINT = "https://api.ipgeolocation.io/ipgeo?apiKey=$API_KEY&ip=$sourceIp"
            try {
                $response = Invoke-WebRequest -UseBasicParsing -Uri $API_ENDPOINT -ErrorAction Stop
                $responseData = $response.Content | ConvertFrom-Json

                $latitude = $responseData.latitude
                $longitude = $responseData.longitude
                $state_prov = $responseData.state_prov
                if ([string]::IsNullOrEmpty($state_prov)) { $state_prov = "null" }
                $country = $responseData.country_name
                if ([string]::IsNullOrEmpty($country)) { $country = "null" }
            }
            catch {
                Write-Host "API request failed for IP: $sourceIp"
                continue  # Skip this event if the API fails.
            }

            # Build the output log entry. Adjust the fields as necessary.
            $logEntry = "latitude:$latitude,longitude:$longitude,destinationhost:$destinationHost,username:$username,sourcehost:$sourceIp,state:$state_prov,country:$country,label:$country - $sourceIp,timestamp:$timestamp"
            
            # Check if this log entry already exists in the file (using the timestamp as a key)
            $log_contents = Get-Content -Path $LOGFILE_PATH
            if (-Not ($log_contents -match [regex]::Escape($timestamp)) -or ($log_contents.Length -eq 0)) {
                $logEntry | Out-File $LOGFILE_PATH -Append -Encoding utf8
                Write-Host $logEntry -ForegroundColor Magenta
            }
            else {
                # Optionally, indicate that the event is a duplicate.
                # Write-Host "Duplicate event, skipping..."
            }
        }
    }
}
