<#
.SYNOPSIS
    List all registered models in MLflow
.DESCRIPTION
    PowerShell equivalent of list_model.sh
#>

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
# Variables
# =====================
$PYTHON_SCRIPT = Join-Path $PROJECT_ROOT "src\scripts\register_model.py"
$CONFIG_PATH = Join-Path $PROJECT_ROOT "src\config\config.yaml"

# =====================
# List All Registered Models
# =====================
Write-Host "Listing all registered models..."
Write-Host ""

python $PYTHON_SCRIPT `
    --config $CONFIG_PATH `
    list

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
