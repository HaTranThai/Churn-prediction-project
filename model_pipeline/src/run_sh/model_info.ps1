<#
.SYNOPSIS
    Get information for a registered model
.DESCRIPTION
    PowerShell equivalent of model_info.sh
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

# IMPORTANT: Update with your model name
$MODEL_NAME = "xgboost_churn_model"

# =====================
# Get Model Info
# =====================
Write-Host "Getting information for model: $MODEL_NAME"
Write-Host ""

python $PYTHON_SCRIPT `
    --config $CONFIG_PATH `
    info `
    --model-name $MODEL_NAME

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
