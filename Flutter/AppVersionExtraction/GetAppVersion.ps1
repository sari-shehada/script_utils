# scripts/get_app_version.ps1
# PowerShell script to extract version and build number from pubspec.yaml

# Get the path to pubspec.yaml (relative to the script location)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# This line assumes your script lives in this path relative to pubspec.yaml file
# scripts/your_script.ps1
# you can adjust this to better match where your script is located
$pubspecPath = Join-Path $scriptDir "..\pubspec.yaml"

if (-Not (Test-Path $pubspecPath)) {
    Write-Error "pubspec.yaml not found at $pubspecPath"
    exit 1
}

# Read the pubspec.yaml file
$content = Get-Content $pubspecPath

# Find the line that starts with 'version:'
$versionLine = $content | Where-Object { $_ -match "^version:" }

if (-Not $versionLine) {
    Write-Error "Version not found in pubspec.yaml"
    exit 1
}

# Extract the version info (format: x.y.z+build)
if ($versionLine -match "version:\s*([\d\.]+)\+(\d+)") {
    $versionName = $matches[1]
    $buildNumber = $matches[2]
    $fullVersion = "$versionName+$buildNumber"

    Write-Host "Version: $fullVersion"
    Write-Host "Version Name: $versionName"
    Write-Host "Build Number: $buildNumber"

    # Optional: export to environment variables for GitHub Actions
    if ($env:GITHUB_ENV) {
        Write-Output "VERSION_NAME=$versionName" >> $env:GITHUB_ENV
        Write-Output "BUILD_NUMBER=$buildNumber" >> $env:GITHUB_ENV
        Write-Output "FULL_VERSION=$fullVersion" >> $env:GITHUB_ENV
    }
}
else {
    Write-Error "Invalid version format in pubspec.yaml. Expected: x.y.z+build"
    exit 1
}
