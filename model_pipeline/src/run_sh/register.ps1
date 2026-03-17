<#
.SYNOPSIS
    Register a trained model to MLflow Model Registry
.DESCRIPTION
    PowerShell equivalent of register.sh
#>

param(
    [string]$RunId,
    [string]$ModelName = "test_logistic_regression_v1.1",
    [string]$ArtifactPath = "logistic_regression_churn",
    [string]$Description = "Logistic Regression model for customer churn prediction",
    [string]$Config,
    [string]$PythonScript,
    [switch]$Help
)

# =====================
# Usage
# =====================
function Show-Usage {
    Write-Host "Usage: .\register.ps1 -RunId RUN_ID [options]"
    Write-Host ""
    Write-Host "Required:"
    Write-Host "  -RunId RUN_ID            MLflow run ID to register"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -ModelName NAME          Model name"
    Write-Host "  -Description TEXT        Model description"
    Write-Host "  -Config PATH             Path to config YAML"
    Write-Host "  -PythonScript PATH       Path to register_model.py"
    Write-Host "  -Help                    Show this help message"
    exit 1
}

if ($Help) { Show-Usage }

# =====================
# Resolve paths
# =====================
$SCRIPT_DIR = $PSScriptRoot
$PROJECT_ROOT = (Resolve-Path (Join-Path $SCRIPT_DIR "..\..")).Path

if (-not $PythonScript) {
    $PythonScript = Join-Path $PROJECT_ROOT "src\scripts\register_model.py"
}
if (-not $Config) {
    $Config = Join-Path $PROJECT_ROOT "src\config\logistic_regression.yaml"
}

Write-Host "SCRIPT_DIR: $SCRIPT_DIR"
Write-Host "PROJECT_ROOT: $PROJECT_ROOT"

# =====================
# Validate required args
# =====================
if (-not $RunId) {
    Write-Host "ERROR: -RunId is required"
    Show-Usage
}

# =====================
# Python path
# =====================
$env:PYTHONPATH = $PROJECT_ROOT

# =====================
# Echo config
# =====================
Write-Host "PYTHON_SCRIPT: $PythonScript"
Write-Host "CONFIG_PATH: $Config"
Write-Host "RUN_ID: $RunId"
Write-Host "MODEL_NAME: $ModelName"
Write-Host "DESCRIPTION: $Description"

# =====================
# Register model
# =====================
Write-Host "Registering model from run: $RunId"

python $PythonScript `
    --config $Config `
    register `
    --run-id $RunId `
    --model-name $ModelName `
    --artifact-path $ArtifactPath `
    --description $Description

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
