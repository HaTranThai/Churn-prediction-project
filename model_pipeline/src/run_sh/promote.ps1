<#
.SYNOPSIS
    Promote a model version to champion
.DESCRIPTION
    PowerShell equivalent of promote.sh
#>

param(
    [string]$ModelName = "test_logistic_regression_v1.1",
    [string]$Version = "5",
    [string]$Config,
    [string]$PythonScript,
    [switch]$Help
)

# =====================
# Usage
# =====================
function Show-Usage {
    Write-Host "Usage: .\promote.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -ModelName NAME      Model name to promote (required)"
    Write-Host "  -Version VERSION     Model version to promote (required)"
    Write-Host "  -Config PATH         Path to config YAML"
    Write-Host "  -PythonScript PATH   Path to register_model.py"
    Write-Host "  -Help                Show this help message"
    exit 1
}

if ($Help) { Show-Usage }

# =====================
# Resolve paths
# =====================
$SCRIPT_DIR = $PSScriptRoot
$PROJECT_ROOT = (Resolve-Path (Join-Path $SCRIPT_DIR "..\..")).Path

Write-Host "SCRIPT_DIR: $SCRIPT_DIR"
Write-Host "PROJECT_ROOT: $PROJECT_ROOT"

# =====================
# Python path
# =====================
$env:PYTHONPATH = $PROJECT_ROOT

# =====================
# Defaults
# =====================
if (-not $PythonScript) {
    $PythonScript = Join-Path $PROJECT_ROOT "src\scripts\register_model.py"
}
if (-not $Config) {
    $Config = Join-Path $PROJECT_ROOT "src\config\logistic_regression.yaml"
}

# =====================
# Validate required args
# =====================
if (-not $ModelName) {
    Write-Host "ERROR: -ModelName is required"
    Show-Usage
}
if (-not $Version) {
    Write-Host "ERROR: -Version is required"
    Show-Usage
}

# =====================
# Echo config
# =====================
Write-Host "PYTHON_SCRIPT: $PythonScript"
Write-Host "CONFIG_PATH: $Config"
Write-Host "MODEL_NAME: $ModelName"
Write-Host "VERSION: $Version"

# =====================
# Promote Model
# =====================
Write-Host "Promoting model: $ModelName version $Version to champion"

python $PythonScript `
    --config $Config `
    promote `
    --model-name $ModelName `
    --version $Version

Write-Host "Transitioning model: $ModelName version $Version to Production stage"

python $PythonScript `
    --config $Config `
    transition-stage `
    --model-name $ModelName `
    --version $Version `
    --stage "Production"

Write-Host ""
Write-Host "Model promoted successfully!"
Write-Host "Model is now available as: models:/$ModelName@champion"

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
