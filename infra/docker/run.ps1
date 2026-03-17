<#
.SYNOPSIS
    Manage all platform Docker Compose services
.DESCRIPTION
    PowerShell equivalent of run.sh
    Usage: .\run.ps1 [up|down|restart|status|help]
#>

param(
    [Parameter(Position = 0)]
    [ValidateSet("up", "down", "restart", "status", "help")]
    [string]$Command
)

$ErrorActionPreference = "Stop"

# Get the directory where the script is located
$SCRIPT_DIR = $PSScriptRoot

# Services array
$SERVICES = @("mlflow", "kafka", "monitor", "airflow")

# Function to print colored messages
function Print-Message {
    param(
        [string]$Color,
        [string]$Message
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to start all services
function Start-Services {
    Print-Message "Green" "Starting all platform services..."
    Write-Host ""

    foreach ($service in $SERVICES) {
        $servicePath = Join-Path $SCRIPT_DIR $service
        $composePath = Join-Path $servicePath "docker-compose.yaml"
        if ((Test-Path $servicePath) -and (Test-Path $composePath)) {
            Print-Message "Cyan" "Starting $service..."
            Push-Location $servicePath
            docker compose up -d
            Pop-Location
            Write-Host ""
        }
        else {
            Print-Message "Yellow" "Warning: $service directory or docker-compose.yaml not found"
        }
    }

    Print-Message "Green" "All services started successfully!"
}

# Function to stop all services
function Stop-Services {
    Print-Message "Red" "Stopping all platform services..."
    Write-Host ""

    foreach ($service in $SERVICES) {
        $servicePath = Join-Path $SCRIPT_DIR $service
        $composePath = Join-Path $servicePath "docker-compose.yaml"
        if ((Test-Path $servicePath) -and (Test-Path $composePath)) {
            Print-Message "Cyan" "Stopping $service..."
            Push-Location $servicePath
            docker compose down
            Pop-Location
            Write-Host ""
        }
        else {
            Print-Message "Yellow" "Warning: $service directory or docker-compose.yaml not found"
        }
    }

    Print-Message "Green" "All services stopped successfully!"
}

# Function to restart all services
function Restart-Services {
    Print-Message "Yellow" "Restarting all platform services..."
    Write-Host ""
    Stop-Services
    Write-Host ""
    Start-Services
}

# Function to show status of all services
function Get-ServicesStatus {
    Print-Message "Cyan" "Checking status of all platform services..."
    Write-Host ""

    foreach ($service in $SERVICES) {
        $servicePath = Join-Path $SCRIPT_DIR $service
        $composePath = Join-Path $servicePath "docker-compose.yaml"
        if ((Test-Path $servicePath) -and (Test-Path $composePath)) {
            Print-Message "Cyan" "Status of ${service}:"
            Push-Location $servicePath
            docker compose ps
            Pop-Location
            Write-Host ""
        }
        else {
            Print-Message "Yellow" "Warning: $service directory or docker-compose.yaml not found"
        }
    }
}

# Function to show help
function Show-Help {
    Write-Host "Platform Services Management Script"
    Write-Host ""
    Write-Host "Usage: .\run.ps1 [command]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  up        - Start all platform services"
    Write-Host "  down      - Stop all platform services"
    Write-Host "  restart   - Restart all platform services"
    Write-Host "  status    - Show status of all platform services"
    Write-Host "  help      - Show this help message"
    Write-Host ""
    Write-Host "Services managed:"
    foreach ($service in $SERVICES) {
        Write-Host "  - $service"
    }
}

# Main script logic
switch ($Command) {
    "up"      { Start-Services }
    "down"    { Stop-Services }
    "restart" { Restart-Services }
    "status"  { Get-ServicesStatus }
    "help"    { Show-Help }
    default {
        Print-Message "Red" "Error: Invalid or missing command '$Command'"
        Write-Host ""
        Show-Help
        exit 1
    }
}
