<#
.SYNOPSIS
    Get Kubernetes Dashboard Access Token
.DESCRIPTION
    PowerShell equivalent of get-dashboard-token.sh
    Retrieves the admin user token for logging into the dashboard
#>

$ErrorActionPreference = "Stop"

Write-Host "🔑 Kubernetes Dashboard Access Token"
Write-Host ("━" * 52)
Write-Host ""

# Check if token file exists
if (Test-Path "dashboard-token.txt") {
    Write-Host "📄 Using saved token from dashboard-token.txt:"
    Write-Host ""
    Get-Content "dashboard-token.txt"
}
else {
    Write-Host "⚠️  Token file not found. Generating new token..."
    Write-Host ""
    try {
        $TOKEN = kubectl -n kubernetes-dashboard create token admin-user --duration=87600h 2>$null
        if ($TOKEN) {
            $TOKEN | Out-File -FilePath "dashboard-token.txt" -Encoding UTF8 -NoNewline
            Write-Host $TOKEN
        }
        else {
            throw "Empty token"
        }
    }
    catch {
        Write-Host "❌ Failed to create token. Make sure the admin-user service account exists."
        Write-Host ""
        Write-Host "To create it, run:"
        Write-Host "  kubectl apply -f dashboard/dashboard-rbac.yaml"
        exit 1
    }
}

Write-Host ""
Write-Host ("━" * 52)
Write-Host ""
Write-Host "📋 How to use this token:"
Write-Host ""
Write-Host "1. Start kubectl proxy:"
Write-Host "   kubectl proxy"
Write-Host ""
Write-Host "2. Open the dashboard URL:"
Write-Host "   http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
Write-Host ""
Write-Host "3. Select 'Token' and paste the token above"
Write-Host ""
Write-Host "Alternative access method (port-forward):"
Write-Host "   kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443"
Write-Host "   Then open: https://localhost:8443"
Write-Host ""
Write-Host "💡 Tip: The token is saved in dashboard-token.txt for future use"
