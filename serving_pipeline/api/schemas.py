from pydantic import BaseModel, Field
from typing import Literal
from typing import Optional

class ChurnInput(BaseModel):
    """Input schema for churn prediction"""
    
    age: int = Field(..., ge=18, le=65, description="Customer age")
    gender: Literal["Male", "Female"] = Field(..., description="Customer gender")
    tenure_months: int = Field(..., ge=1, le=60, description="Months with company")
    usage_frequency: int = Field(..., ge=1, le=30, description="Monthly usage frequency")
    support_calls: int = Field(..., ge=0, le=10, description="Number of support calls")
    payment_delay_days: int = Field(..., ge=0, le=30, description="Payment delay in days")
    subscription_type: Literal["Basic", "Standard", "Premium"] = Field(..., description="Subscription tier")
    contract_length: Literal["Monthly", "Quarterly", "Annual"] = Field(..., description="Contract duration")
    total_spend: float = Field(..., ge=100, le=1000, description="Total amount spent")
    last_interaction_days: int = Field(..., ge=1, le=30, description="Days since last interaction")
    
    class Config:
        json_schema_extra = {
            "example": {
                "age": 30,
                "gender": "Female",
                "tenure_months": 39,
                "usage_frequency": 14,
                "support_calls": 5,
                "payment_delay_days": 18,
                "subscription_type": "Standard",
                "contract_length": "Annual",
                "total_spend": 932.0,
                "last_interaction_days": 17
            }
        }


class ChurnPrediction(BaseModel):
    """Prediction response"""
    churn: int = Field(..., description="Predicted churn (0=Active, 1=Churn)")


class HealthResponse(BaseModel):
    """Health check response"""
    status: str
    model_loaded: bool
    timestamp: str

class DriftMetricsResponse(BaseModel):
    """Response schema for drift metrics"""
    overall_drift_score: float = Field(..., description="Overall drift score (0-1)")
    drift_status: str = Field(..., description="Drift status: LOW/MEDIUM/HIGH")
    dataset_drift: Optional[bool] = Field(None, description="Whether dataset drift detected")
    number_of_drifted_features: Optional[int] = Field(None, description="Number of features with drift")
    total_features: Optional[int] = Field(None, description="Total number of features")
    drift_by_feature: Optional[dict] = Field(None, description="Drift details by feature")
    target_drift: Optional[bool] = Field(None, description="Whether target drift detected")
    prediction_drift: Optional[bool] = Field(None, description="Whether prediction drift detected")
    performance: Optional[dict] = Field(None, description="Performance metrics comparison")
    reference_data_size: int = Field(..., description="Size of reference dataset")
    current_data_size: int = Field(..., description="Size of current dataset")
    timestamp: str = Field(..., description="Timestamp of drift check")