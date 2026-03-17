<#
.SYNOPSIS
    Deploy MLOps Infrastructure to Kubernetes
.DESCRIPTION
    PowerShell equivalent of deploy.sh
    Deploys PostgreSQL, MinIO, MLflow, Kafka, Airflow, and Kubernetes Dashboard
#>

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting MLOps Infrastructure Deployment..."

# Check if kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "❌ kubectl is not installed. Please install kubectl first."
    exit 1
}

# Create namespace
Write-Host "📦 Creating namespace..."
kubectl apply -f namespace.yaml

# Deploy PostgreSQL
Write-Host "🐘 Deploying PostgreSQL..."
kubectl apply -f postgres/postgres-secret.yaml
kubectl apply -f postgres/postgres-pvc.yaml
kubectl apply -f postgres/postgres-deployment.yaml
kubectl apply -f postgres/postgres-service.yaml

# Wait for PostgreSQL to be ready
Write-Host "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n mlops --timeout=120s

# Deploy MinIO
Write-Host "📦 Deploying MinIO..."
kubectl apply -f minio/minio-secret.yaml
kubectl apply -f minio/minio-pvc.yaml
kubectl apply -f minio/minio-deployment.yaml
kubectl apply -f minio/minio-service.yaml

# Wait for MinIO to be ready
Write-Host "⏳ Waiting for MinIO to be ready..."
kubectl wait --for=condition=ready pod -l app=minio -n mlops --timeout=120s

# Create MinIO bucket
Write-Host "🪣 Creating MinIO bucket..."
kubectl apply -f minio/minio-bucket-job.yaml
kubectl wait --for=condition=complete job/minio-create-bucket -n mlops --timeout=60s

# Deploy MLflow
Write-Host "📊 Deploying MLflow tracking server..."
kubectl apply -f mlflow/mlflow-config.yaml
kubectl apply -f mlflow/mlflow-deployment.yaml
kubectl apply -f mlflow/mlflow-service.yaml

# Wait for MLflow to be ready
Write-Host "⏳ Waiting for MLflow to be ready..."
kubectl wait --for=condition=ready pod -l app=mlflow -n mlops --timeout=180s

# Deploy Kafka Cluster
Write-Host "📨 Deploying Kafka cluster (3 brokers)..."
kubectl apply -f kafka/kafka-config.yaml
kubectl apply -f kafka/kafka-statefulset.yaml
kubectl apply -f kafka/kafka-service.yaml

# Wait for Kafka to be ready
Write-Host "⏳ Waiting for Kafka cluster to be ready..."
kubectl wait --for=condition=ready pod -l app=kafka -n mlops --timeout=180s

# Deploy Kafka UI
Write-Host "🖥️  Deploying Kafka UI..."
kubectl apply -f kafka/kafka-ui-deployment.yaml
kubectl apply -f kafka/kafka-ui-service.yaml

# Wait for Kafka UI to be ready
Write-Host "⏳ Waiting for Kafka UI to be ready..."
kubectl wait --for=condition=ready pod -l app=kafka-ui -n mlops --timeout=120s

# Deploy Kubernetes Dashboard
Write-Host "🎛️  Deploying Kubernetes Dashboard..."
kubectl apply -f dashboard/dashboard-namespace.yaml
kubectl apply -f dashboard/dashboard-serviceaccount.yaml
kubectl apply -f dashboard/dashboard-rbac.yaml
kubectl apply -f dashboard/dashboard-secret.yaml
kubectl apply -f dashboard/dashboard-configmap.yaml
kubectl apply -f dashboard/dashboard-deployment.yaml
kubectl apply -f dashboard/dashboard-service.yaml

# Wait for Dashboard to be ready
Write-Host "⏳ Waiting for Kubernetes Dashboard to be ready..."
kubectl wait --for=condition=ready pod -l k8s-app=kubernetes-dashboard -n kubernetes-dashboard --timeout=120s

# Create admin token
Write-Host ""
Write-Host "🔑 Creating dashboard admin token..."
$TOKEN = $null
try {
    $TOKEN = kubectl -n kubernetes-dashboard create token admin-user --duration=87600h 2>$null
}
catch {}

if (-not $TOKEN) {
    Write-Host "⚠️  Token creation failed. Creating token using Secret method..."

    $secretYaml = @"
apiVersion: v1
kind: Secret
metadata:
  name: admin-user-token
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: admin-user
type: kubernetes.io/service-account-token
"@
    $secretYaml | kubectl apply -f -

    Start-Sleep -Seconds 2
    $tokenBase64 = kubectl get secret admin-user-token -n kubernetes-dashboard -o jsonpath='{.data.token}'
    $TOKEN = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($tokenBase64))
}

if ($TOKEN) {
    $TOKEN | Out-File -FilePath "dashboard-token.txt" -Encoding UTF8 -NoNewline
    Write-Host "💾 Token saved to: dashboard-token.txt"
}

Write-Host ""
Write-Host "✅ MLOps Infrastructure deployed successfully!"
Write-Host ""
Write-Host "📋 Deployment Summary:"
Write-Host "  - Namespace: mlops"
Write-Host "  - PostgreSQL: postgres.mlops.svc.cluster.local:5432"
Write-Host "  - MinIO API: minio.mlops.svc.cluster.local:9000"
Write-Host "  - MinIO Console: minio.mlops.svc.cluster.local:9001"
Write-Host "  - MLflow: mlflow.mlops.svc.cluster.local:5000"
Write-Host "  - Kafka Cluster: kafka-0, kafka-1, kafka-2 (port 9092)"
Write-Host "  - Kafka UI: kafka-ui.mlops.svc.cluster.local:8080"
Write-Host "  - Airflow: airflow-webserver.mlops.svc.cluster.local:8080"
Write-Host "  - Kubernetes Dashboard: kubernetes-dashboard namespace"
Write-Host ""
Write-Host "🔍 To check the status of all pods:"
Write-Host "  kubectl get pods -n mlops"
Write-Host "  kubectl get pods -n kubernetes-dashboard"
Write-Host ""
Write-Host "🌐 To access MLflow UI:"
Write-Host "  kubectl port-forward svc/mlflow -n mlops 5000:5000"
Write-Host "  Then open http://localhost:5000"
Write-Host ""
Write-Host "🌐 To access MinIO Console:"
Write-Host "  kubectl port-forward svc/minio -n mlops 9001:9001"
Write-Host "  Then open http://localhost:9001"
Write-Host "  Login: minio / minio123"
Write-Host ""
Write-Host "📨 To access Kafka brokers:"
Write-Host "  kafka-0.kafka-headless.mlops.svc.cluster.local:9092"
Write-Host "  kafka-1.kafka-headless.mlops.svc.cluster.local:9092"
Write-Host "  kafka-2.kafka-headless.mlops.svc.cluster.local:9092"
Write-Host ""
Write-Host "🖥️  To access Kafka UI:"
Write-Host "  kubectl port-forward svc/kafka-ui -n mlops 8080:8080"
Write-Host "  Then open http://localhost:8080"
Write-Host ""

# Deploy Airflow
Write-Host "✈️  Deploying Apache Airflow..."
kubectl apply -f airflow/airflow-rbac.yaml
kubectl apply -f airflow/airflow-secret.yaml
kubectl apply -f airflow/airflow-passwords.yaml
kubectl apply -f airflow/airflow-config.yaml
kubectl apply -f airflow/airflow-pvc.yaml
kubectl apply -f airflow/airflow-postgres.yaml

# Wait for Airflow PostgreSQL to be ready
Write-Host "⏳ Waiting for Airflow PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=airflow-postgres -n mlops --timeout=300s

# Deploy Airflow components
kubectl apply -f airflow/airflow-scheduler.yaml
kubectl apply -f airflow/airflow-webserver.yaml

# Wait for Airflow to be ready
Write-Host "⏳ Waiting for Airflow to be ready..."
kubectl wait --for=condition=ready pod -l app=airflow-webserver -n mlops --timeout=300s

Write-Host ""
Write-Host "🎛️  To access Kubernetes Dashboard:"
Write-Host "  kubectl proxy"
Write-Host "  Then open: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
Write-Host "  OR use: kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443"
Write-Host "  Then open: https://localhost:8443"
Write-Host ""
if (Test-Path "dashboard-token.txt") {
    Write-Host "🔑 Dashboard Token (for login):"
    Write-Host ("━" * 52)
    Get-Content "dashboard-token.txt"
    Write-Host ""
    Write-Host ("━" * 52)
}
Write-Host ""
Write-Host "✈️  To access Airflow UI:"
Write-Host "  kubectl port-forward svc/airflow-webserver -n mlops 8080:8080"
Write-Host "  Then open http://localhost:8080"
Write-Host "  Login: admin / admin123"
Write-Host ""
Write-Host "✅ Deployment complete!"
