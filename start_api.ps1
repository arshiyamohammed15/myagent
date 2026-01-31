# CI/CD Test Commit
# PowerShell script to start the Planner Agent API
# Usage: .\start_api.ps1

Write-Host "=== Starting Planner Agent API ===" -ForegroundColor Cyan
Write-Host ""

# Set environment variables
Write-Host "Setting up environment variables..." -ForegroundColor Yellow
$env:PLANNER_API_SECRET = "test-secret-key"
$env:POSTGRES_USER = "postgres"
$env:POSTGRES_PASSWORD = "Arshiya@10"
$env:POSTGRES_HOST = "localhost"
$env:POSTGRES_PORT = "5432"
$env:POSTGRES_DB = "mydatabase"

Write-Host "Environment variables set:" -ForegroundColor Green
Write-Host "  PLANNER_API_SECRET: $env:PLANNER_API_SECRET"
Write-Host "  POSTGRES_USER: $env:POSTGRES_USER"
Write-Host "  POSTGRES_HOST: $env:POSTGRES_HOST"
Write-Host "  POSTGRES_DB: $env:POSTGRES_DB"
Write-Host ""

# Check if port 8000 is available
$portCheck = Test-NetConnection -ComputerName localhost -Port 8000 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($portCheck) {
    Write-Host "⚠ Port 8000 is already in use!" -ForegroundColor Yellow
    Write-Host "  The API might already be running." -ForegroundColor Yellow
    Write-Host "  Access it at: http://localhost:8000" -ForegroundColor Cyan
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 0
    }
}

Write-Host "Starting API server..." -ForegroundColor Yellow
Write-Host "  URL: http://localhost:8000" -ForegroundColor Cyan
Write-Host "  Docs: http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Start the API server
python -m uvicorn api.planner_api:app --host 0.0.0.0 --port 8000 --reload

