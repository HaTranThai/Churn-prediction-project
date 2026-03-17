<#
.SYNOPSIS
    Build Custom Airflow Docker Image
.DESCRIPTION
    PowerShell equivalent of build-airflow-image.sh
#>

$ErrorActionPreference = "Stop"

# Configuration
$IMAGE_NAME = "airflow-mlops"
$IMAGE_TAG = "3.1.5-custom"
$REGISTRY = if ($env:DOCKER_REGISTRY) { $env:DOCKER_REGISTRY } else { "localhost:5000" }

$FULL_IMAGE = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

Write-Host "======================================"
Write-Host "Building Custom Airflow Image"
Write-Host "======================================"
Write-Host "Image: $FULL_IMAGE"
Write-Host ""

# Build the image
Write-Host "Building Docker image..."
docker build -t $FULL_IMAGE -f airflow/Dockerfile airflow/

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "======================================"
Write-Host "Build complete!"
Write-Host "======================================"
Write-Host ""
Write-Host "To push to registry:"
Write-Host "  docker push $FULL_IMAGE"
Write-Host ""
Write-Host "To use in Kubernetes:"
Write-Host "  Update airflow-config.yaml:"
Write-Host "    AIRFLOW__KUBERNETES_EXECUTOR__WORKER_CONTAINER_REPOSITORY: `"${REGISTRY}/${IMAGE_NAME}`""
Write-Host "    AIRFLOW__KUBERNETES_EXECUTOR__WORKER_CONTAINER_TAG: `"${IMAGE_TAG}`""
Write-Host ""
Write-Host "  Update airflow-webserver.yaml and airflow-scheduler.yaml:"
Write-Host "    image: $FULL_IMAGE"
Write-Host ""
