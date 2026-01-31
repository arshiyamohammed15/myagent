# Simple PowerShell script to manage Planner Agent servers

param(
    [switch]$Status,
    [switch]$Stop,
    [switch]$Restart
)

$ApiPort = 8080
$FrontendPort = 8000

function Test-Port {
    param([int]$Port)
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue
        return $connection
    } catch {
        return $false
    }
}

function Start-ApiServer {
    Write-Host "Starting API Server on port $ApiPort..." -ForegroundColor Yellow

    # Set environment variables
    $env:PLANNER_API_SECRET = "test-secret-key"
    $env:POSTGRES_USER = "postgres"
    $env:POSTGRES_PASSWORD = "Arshiya@10"
    $env:POSTGRES_HOST = "localhost"
    $env:POSTGRES_PORT = "5432"
    $env:POSTGRES_DB = "mydatabase"

    # Start server in background
    Start-Job -ScriptBlock {
        param($port)
        python -m uvicorn api.planner_api:app --host 0.0.0.0 --port $port --reload
    } -ArgumentList $ApiPort | Out-Null

    Start-Sleep -Seconds 3
    if (Test-Port -Port $ApiPort) {
        Write-Host "✓ API Server started on port $ApiPort" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ API Server failed to start" -ForegroundColor Red
        return $false
    }
}

function Start-FrontendServer {
    Write-Host "Starting Frontend Server on port $FrontendPort..." -ForegroundColor Yellow

    # Start simple HTTP server for frontend
    Start-Job -ScriptBlock {
        param($port)
        cd frontend
        python -m http.server $port
    } -ArgumentList $FrontendPort | Out-Null

    Start-Sleep -Seconds 2
    if (Test-Port -Port $FrontendPort) {
        Write-Host "✓ Frontend Server started on port $FrontendPort" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ Frontend Server failed to start" -ForegroundColor Red
        return $false
    }
}

function Check-Status {
    Write-Host "=== Server Status ===" -ForegroundColor Cyan

    if (Test-Port -Port $ApiPort) {
        Write-Host "✓ API Server: RUNNING on port $ApiPort" -ForegroundColor Green
        Write-Host "  API Docs: http://localhost:$ApiPort/docs" -ForegroundColor Cyan
    } else {
        Write-Host "✗ API Server: STOPPED" -ForegroundColor Red
    }

    if (Test-Port -Port $FrontendPort) {
        Write-Host "✓ Frontend Server: RUNNING on port $FrontendPort" -ForegroundColor Green
        Write-Host "  Frontend: http://localhost:$FrontendPort/task_page_example.html" -ForegroundColor Cyan
    } else {
        Write-Host "✗ Frontend Server: STOPPED" -ForegroundColor Red
    }
}

function Stop-AllServers {
    Write-Host "Stopping all servers..." -ForegroundColor Yellow

    # Kill processes on both ports
    $processes = Get-Process | Where-Object { $_.ProcessName -eq "python" }
    foreach ($process in $processes) {
        try {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        } catch {
            # Ignore errors
        }
    }

    Write-Host "✓ All servers stopped" -ForegroundColor Green
}

# Main logic
if ($Status) {
    Check-Status
} elseif ($Stop) {
    Stop-AllServers
    Check-Status
} elseif ($Restart) {
    Stop-AllServers
    Start-Sleep -Seconds 2
    Start-ApiServer | Out-Null
    Start-FrontendServer | Out-Null
    Check-Status
} else {
    # Default: start both servers
    Write-Host "Planner Agent Server Manager" -ForegroundColor Cyan
    Write-Host ""

    $apiStarted = Start-ApiServer
    $frontendStarted = Start-FrontendServer

    Write-Host ""
    if ($apiStarted -and $frontendStarted) {
        Write-Host "🎉 Both servers started successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Access URLs:" -ForegroundColor Cyan
        Write-Host "  Frontend: http://localhost:$FrontendPort/task_page_example.html" -ForegroundColor White
        Write-Host "  API Docs: http://localhost:$ApiPort/docs" -ForegroundColor White
    } else {
        Write-Host "❌ Some servers failed to start. Use -Status to check." -ForegroundColor Red
    }
}