<#
.SYNOPSIS
    Set an alias for a registered model version
.DESCRIPTION
    PowerShell equivalent of set_model_alias.sh
#>

param(
    [string]$ModelName = "test_logistic_regression_v1.1",
    [string]$Version = "5",
    [string]$Alias = "staging",
    [string]$Config,
    [string]$PythonScript,
    [switch]$Help
)

# =====================
# Usage
# =====================
function Show-Usage {
    Write-Host "Usage: .\set_model_alias.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -ModelName NAME        Model name (required)"
    Write-Host "  -Version VERSION       Model version to alias (required)"
    Write-Host "  -Alias NAME            Alias to set (e.g. staging, champion, production)"
    Write-Host "  -Config PATH           Path to config YAML"
    Write-Host "  -PythonScript PATH     Path to register_model.py"
    Write-Host "  -Help                  Show this help message"
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
Write-Host "ALIAS: $Alias"

# =====================
# Register / Set alias
# =====================
Write-Host "Setting alias '$Alias' for model: $ModelName version $Version"

python $PythonScript `
    --config $Config `
    set-alias `
    --model-name $ModelName `
    --version $Version `
    --alias $Alias

Write-Host ""
Write-Host "Alias set successfully!"
Write-Host "Model can now be loaded with: models:/$ModelName@$Alias"

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
