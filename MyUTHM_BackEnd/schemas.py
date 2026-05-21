from pydantic import BaseModel
from typing import Optional

class NextOfKinSchema(BaseModel):
    name: str
    relationship: str
    phone: str

    class Config:
        from_attributes = True

class AcademicRecordSchema(BaseModel):
    current_gpa: Optional[str]
    current_cpa: Optional[str]
    credits_obtained: Optional[int]
    credits_total: Optional[int]
    outstanding_debt: Optional[str]
    current_week: Optional[int]
    total_weeks: Optional[int]

    class Config:
        from_attributes = True

class ProfileResponse(BaseModel):
    matric_no: str
    full_name: str
    faculty: str
    course: str
    email: str
    phone: Optional[str]
    session_enroll: Optional[str]
    next_of_kin: Optional[NextOfKinSchema]
    academic: Optional[AcademicRecordSchema]

    class Config:
        from_attributes = True
