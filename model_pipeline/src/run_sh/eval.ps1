<#
.SYNOPSIS
    Evaluate a trained model
.DESCRIPTION
    PowerShell equivalent of eval.sh
#>

param(
    [string]$RunId,
    [string]$Config,
    [string]$EvalDataPath,
    [string]$OutputPathPrediction,
    [string]$PythonScript,
    [switch]$NoValidateThresholds,
    [switch]$Help
)

# =====================
# Usage
# =====================
function Show-Usage {
    Write-Host "Usage: .\eval.ps1 -RunId RUN_ID [options]"
    Write-Host ""
    Write-Host "Required:"
    Write-Host "  -RunId RUN_ID                 MLflow run ID to evaluate"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Config PATH                  Path to config YAML"
    Write-Host "  -EvalDataPath PATH            Path to evaluation dataset"
    Write-Host "  -OutputPathPrediction PATH    Path to save predictions"
    Write-Host "  -PythonScript PATH            Path to eval script"
    Write-Host "  -NoValidateThresholds         Disable threshold validation"
    Write-Host "  -Help                         Show this help message"
    exit 1
}

if ($Help) { Show-Usage }

# =====================
# Resolve paths
# =====================
$SCRIPT_DIR = $PSScriptRoot
$PROJECT_ROOT = (Resolve-Path (Join-Path $SCRIPT_DIR "..\..")).Path

# =====================
# Defaults
# =====================
if (-not $PythonScript) {
    $PythonScript = Join-Path $PROJECT_ROOT "src\scripts\eval.py"
}
if (-not $Config) {
    $Config = Join-Path $PROJECT_ROOT "src\config\logistic_regression.yaml"
}
if (-not $EvalDataPath) {
    $EvalDataPath = Join-Path $PROJECT_ROOT "src\data\test.csv"
}
if (-not $OutputPathPrediction) {
    $OutputPathPrediction = Join-Path $PROJECT_ROOT "prediction_folder\prediction11.csv"
}

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
Write-Host "SCRIPT_DIR: $SCRIPT_DIR"
Write-Host "PROJECT_ROOT: $PROJECT_ROOT"
Write-Host "PYTHON_SCRIPT: $PythonScript"
Write-Host "CONFIG_PATH: $Config"
Write-Host "EVAL_DATASET: $EvalDataPath"
Write-Host "PREDICTION_FOLDER: $OutputPathPrediction"
Write-Host "RUN_ID: $RunId"
Write-Host "VALIDATE_THRESHOLDS: $(-not $NoValidateThresholds)"

# =====================
# Eval
# =====================
$CMD = @(
    $PythonScript,
    "--config", $Config,
    "--run-id", $RunId,
    "--eval-data-path", $EvalDataPath,
    "--output-path-prediction", $OutputPathPrediction
)

if (-not $NoValidateThresholds) {
    $CMD += "--validate-thresholds"
}

python @CMD

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
