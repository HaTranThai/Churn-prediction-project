<#
.SYNOPSIS
    Teardown MLOps Infrastructure from Kubernetes
.DESCRIPTION
    PowerShell equivalent of teardown.sh
    Removes all MLOps infrastructure components including Dashboard
#>

$ErrorActionPreference = "Stop"

Write-Host "🗑️  Starting MLOps Infrastructure Teardown..."

# Check if kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "❌ kubectl is not installed. Please install kubectl first."
    exit 1
}

# Delete Kubernetes Dashboard
Write-Host "🎛️  Deleting Kubernetes Dashboard..."
kubectl delete -f dashboard/dashboard-service.yaml --ignore-not-found=true
kubectl delete -f dashboard/dashboard-deployment.yaml --ignore-not-found=true
kubectl delete -f dashboard/dashboard-configmap.yaml --ignore-not-found=true
kubectl delete -f dashboard/dashboard-secret.yaml --ignore-not-found=true
kubectl delete -f dashboard/dashboard-rbac.yaml --ignore-not-found=true
kubectl delete -f dashboard/dashboard-serviceaccount.yaml --ignore-not-found=true
kubectl delete -f dashboard/dashboard-namespace.yaml --ignore-not-found=true

# Delete token file
if (Test-Path "dashboard-token.txt") {
    Write-Host "💾 Removing saved token file..."
    Remove-Item "dashboard-token.txt"
}

# Delete MLflow
Write-Host "📊 Deleting MLflow tracking server..."
kubectl delete -f mlflow/mlflow-service.yaml --ignore-not-found=true
kubectl delete -f mlflow/mlflow-deployment.yaml --ignore-not-found=true
kubectl delete -f mlflow/mlflow-config.yaml --ignore-not-found=true

# Delete Kafka
Write-Host "📨 Deleting Kafka cluster..."
kubectl delete -f kafka/kafka-ui-service.yaml --ignore-not-found=true
kubectl delete -f kafka/kafka-ui-deployment.yaml --ignore-not-found=true
kubectl delete -f kafka/kafka-service.yaml --ignore-not-found=true
kubectl delete -f kafka/kafka-statefulset.yaml --ignore-not-found=true
kubectl delete -f kafka/kafka-config.yaml --ignore-not-found=true
kubectl delete pvc -l app=kafka -n mlops --ignore-not-found=true

# Delete Airflow
Write-Host "✈️  Deleting Airflow..."
kubectl delete -f airflow/airflow-webserver.yaml --ignore-not-found=true
kubectl delete -f airflow/airflow-scheduler.yaml --ignore-not-found=true
kubectl delete -f airflow/airflow-postgres.yaml --ignore-not-found=true
kubectl delete -f airflow/airflow-pvc.yaml --ignore-not-found=true
kubectl delete -f airflow/airflow-config.yaml --ignore-not-found=true
kubectl delete -f airflow/airflow-secret.yaml --ignore-not-found=true
kubectl delete -f airflow/airflow-rbac.yaml --ignore-not-found=true

# Delete MinIO
Write-Host "📦 Deleting MinIO..."
kubectl delete -f minio/minio-bucket-job.yaml --ignore-not-found=true
kubectl delete -f minio/minio-service.yaml --ignore-not-found=true
kubectl delete -f minio/minio-deployment.yaml --ignore-not-found=true
kubectl delete -f minio/minio-pvc.yaml --ignore-not-found=true
kubectl delete -f minio/minio-secret.yaml --ignore-not-found=true

# Delete PostgreSQL
Write-Host "🐘 Deleting PostgreSQL..."
kubectl delete -f postgres/postgres-service.yaml --ignore-not-found=true
kubectl delete -f postgres/postgres-deployment.yaml --ignore-not-found=true
kubectl delete -f postgres/postgres-pvc.yaml --ignore-not-found=true
kubectl delete -f postgres/postgres-secret.yaml --ignore-not-found=true

# Delete namespace (optional - uncomment if you want to delete the namespace)
# Write-Host "📦 Deleting namespace..."
# kubectl delete -f namespace.yaml --ignore-not-found=true

Write-Host ""
Write-Host "✅ MLOps Infrastructure teardown completed!"
Write-Host ""
Write-Host "⚠️  Note: PersistentVolumes may still exist. To delete them manually:"
Write-Host "  kubectl get pv"
Write-Host "  kubectl delete pv <pv-name>"
Write-Host ""
Write-Host "⚠️  To delete the namespaces (this will remove all resources):"
Write-Host "  kubectl delete namespace mlops"
Write-Host "  kubectl delete namespace kubernetes-dashboard"
