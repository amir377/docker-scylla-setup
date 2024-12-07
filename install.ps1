Write-Host "Starting Docker and ScyllaDB installation..." -ForegroundColor Green

# Define a helper function to prompt the user
function PromptUser {
    param (
        [string]$PromptText,
        [string]$DefaultValue
    )
    $response = Read-Host "$PromptText (Default: $DefaultValue)"
    if ([string]::IsNullOrWhiteSpace($response)) {
        return $DefaultValue
    }
    return $response
}

# Prompt user for each required parameter
$containerName = PromptUser -PromptText "Enter the container name" -DefaultValue "scylla"
$networkName = PromptUser -PromptText "Enter the network name" -DefaultValue "general"
$scyllaCQLPort = PromptUser -PromptText "Enter the ScyllaDB CQL port" -DefaultValue "9042"
$scyllaRESTPort = PromptUser -PromptText "Enter the ScyllaDB REST port" -DefaultValue "9180"
$scyllaUser = PromptUser -PromptText "Enter the ScyllaDB username" -DefaultValue "admin"
$scyllaPassword = PromptUser -PromptText "Enter the ScyllaDB password" -DefaultValue "admin"
$allowHost = PromptUser -PromptText "Enter the allowed host (Default: 0.0.0.0)" -DefaultValue "0.0.0.0"

# Generate the .env file
Write-Host "Creating .env file for ScyllaDB setup..." -ForegroundColor Green
$envContent = @"
# ScyllaDB container settings
CONTAINER_NAME=$containerName
NETWORK_NAME=$networkName
SCYLLA_CQL_PORT=$scyllaCQLPort
SCYLLA_REST_PORT=$scyllaRESTPort
ALLOW_HOST=$allowHost

# ScyllaDB credentials
SCYLLA_USER=$scyllaUser
SCYLLA_PASSWORD=$scyllaPassword
"@

# Save the .env file
$envFilePath = ".env"
$envContent | Set-Content -Path $envFilePath
Write-Host ".env file created successfully at $envFilePath." -ForegroundColor Green

# Check if Docker is installed
if (-Not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not installed. Please install Docker Desktop and restart this script." -ForegroundColor Red
    Start-Process "https://desktop.docker.com/win/stable/Docker Desktop Installer.exe"
    exit
}

# Check if Docker Compose is installed
if (-Not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Compose is not installed. Installing Docker Compose..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://github.com/docker/compose/releases/latest/download/docker-compose-Windows-x86_64.exe" -OutFile "$Env:ProgramFiles\Docker\docker-compose.exe"
    Write-Host "Docker Compose installed successfully." -ForegroundColor Green
}

# Create the network before building the container
Write-Host "Creating Docker network $networkName if it does not already exist..." -ForegroundColor Green
try {
    docker network create $networkName
    Write-Host "Network $networkName created successfully." -ForegroundColor Green
} catch {
    Write-Host "Network $networkName already exists or could not be created. Skipping..." -ForegroundColor Yellow
}

# Use docker-compose.example.yaml to create docker-compose.yaml
Write-Host "Generating docker-compose.yaml file from docker-compose.example.yaml..." -ForegroundColor Green
if (Test-Path "docker-compose.example.yaml") {
    $exampleContent = Get-Content "docker-compose.example.yaml" | ForEach-Object {
        $_ -replace "\$\{CONTAINER_NAME\}", $containerName `
            -replace "\$\{NETWORK_NAME\}", $networkName `
            -replace "\$\{SCYLLA_CQL_PORT\}", $scyllaCQLPort `
            -replace "\$\{SCYLLA_REST_PORT\}", $scyllaRESTPort `
            -replace "\$\{ALLOW_HOST\}", $allowHost `
            -replace "\$\{SCYLLA_USER\}", $scyllaUser `
            -replace "\$\{SCYLLA_PASSWORD\}", $scyllaPassword
    }
    $composeFilePath = "docker-compose.yaml"
    $exampleContent | Set-Content -Path $composeFilePath
    Write-Host "docker-compose.yaml file created successfully at $composeFilePath." -ForegroundColor Green
} else {
    Write-Host "docker-compose.example.yaml file not found. Ensure the example file exists in the current directory." -ForegroundColor Red
    exit
}

# Start Docker Compose with build
Write-Host "Starting Docker Compose with --build for ScyllaDB..." -ForegroundColor Green
try {
    docker-compose up -d --build
    $containerStatus = docker inspect -f '{{.State.Running}}' $containerName
    if ($containerStatus -eq "true") {
        Write-Host "ScyllaDB setup is complete and running. Access it on ports $scyllaCQLPort and $scyllaRESTPort." -ForegroundColor Green
    } else {
        Write-Host "Container is not running. Fetching logs..." -ForegroundColor Yellow
        docker logs $containerName
    }
} catch {
    Write-Host "Failed to start Docker Compose. Ensure Docker is running and try again." -ForegroundColor Red
}