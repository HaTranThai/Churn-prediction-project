import mlflow
import os
from mlflow.tracking import MlflowClient

def check_diag():
    tracking_uri = "http://localhost:5000"
    if os.getenv("MLFLOW_TRACKING_URI"):
        tracking_uri = os.getenv("MLFLOW_TRACKING_URI")
    
    print(f"Tracking URI: {tracking_uri}")
    mlflow.set_tracking_uri(tracking_uri)
    client = MlflowClient()
    
    model_name = "customer_churn_model"
    try:
        versions = client.get_latest_versions(model_name, stages=["Production"])
        if not versions:
            print(f"No Production version found for {model_name}")
            return
        
        v = versions[0]
        print(f"Version: {v.version}")
        print(f"Status: {v.status}")
        print(f"Stage: {v.current_stage}")
        print(f"Run ID: {v.run_id}")
        print(f"Source (Artifact URI): {v.source}")
        
        # Try to list artifacts
        print("\nAttempting to list artifacts...")
        try:
            artifacts = client.list_artifacts(v.run_id)
            print(f"Found {len(artifacts)} artifacts at run level.")
            for art in artifacts:
                print(f" - {art.path}")
        except Exception as e:
            print(f"Error listing artifacts: {e}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_diag()
