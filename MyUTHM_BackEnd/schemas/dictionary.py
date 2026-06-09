from pydantic import BaseModel, ConfigDict
from typing import Optional
from decimal import Decimal

class LocationBase(BaseModel):
    Location_ID: str
    Location_Name: str
    Location_URL: Optional[str] = None
class LocationCreate(LocationBase): pass
class Location(LocationBase):
    model_config = ConfigDict(from_attributes=True)

class PositionBase(BaseModel):
    Position_ID: str
    Position_Name: str
class PositionCreate(PositionBase): pass
class Position(PositionBase):
    model_config = ConfigDict(from_attributes=True)

class VehicleTypeBase(BaseModel):
    Vehicle_Type_ID: str
    Details: Optional[str] = None
class VehicleTypeCreate(VehicleTypeBase): pass
class VehicleType(VehicleTypeBase):
    model_config = ConfigDict(from_attributes=True)

class FacilityBase(BaseModel):
    Facility_ID: str
    Facility_Name: str
class FacilityCreate(FacilityBase): pass
class Facility(FacilityBase):
    model_config = ConfigDict(from_attributes=True)

class LeaveTypeBase(BaseModel):
    Leave_Type_ID: str
    Leave_Name: str
class LeaveTypeCreate(LeaveTypeBase): pass
class LeaveType(LeaveTypeBase):
    model_config = ConfigDict(from_attributes=True)

class AssignmentTypeBase(BaseModel):
    Assignment_Type_ID: str
    Details: Optional[str] = None
class AssignmentTypeCreate(AssignmentTypeBase): pass
class AssignmentType(AssignmentTypeBase):
    model_config = ConfigDict(from_attributes=True)

class SubmissionStatusBase(BaseModel):
    Submission_Status_ID: str
    Status_Type: str
class SubmissionStatusCreate(SubmissionStatusBase): pass
class SubmissionStatus(SubmissionStatusBase):
    model_config = ConfigDict(from_attributes=True)

class ComplaintCategoryBase(BaseModel):
    Complaint_Category_ID: str
    Category: str
class ComplaintCategoryCreate(ComplaintCategoryBase): pass
class ComplaintCategory(ComplaintCategoryBase):
    model_config = ConfigDict(from_attributes=True)

class ComplaintStatusBase(BaseModel):
    Complaint_Status_ID: str
    Complaint_Status: str
class ComplaintStatusCreate(ComplaintStatusBase): pass
class ComplaintStatus(ComplaintStatusBase):
    model_config = ConfigDict(from_attributes=True)

class ReminderStatusBase(BaseModel):
    Reminder_Status_ID: str
    Reminder_Status: str
class ReminderStatusCreate(ReminderStatusBase): pass
class ReminderStatus(ReminderStatusBase):
    model_config = ConfigDict(from_attributes=True)

class ClinicListBase(BaseModel):
    Clinic_ID: str
    Clinic_Name: str
    Clinic_Address: Optional[str] = None
    Clinic_Phone: Optional[str] = None
    Type: Optional[str] = None
class ClinicListCreate(ClinicListBase): pass
class ClinicList(ClinicListBase):
    model_config = ConfigDict(from_attributes=True)

class ApplianceBase(BaseModel):
    Appliance_ID: str
    Appliance_Name: str
    Price: Optional[Decimal] = None
class ApplianceCreate(ApplianceBase): pass
class Appliance(ApplianceBase):
    model_config = ConfigDict(from_attributes=True)

class HostelBase(BaseModel):
    Hostel_ID: str
    Hostel_Name: str
    Blocks: Optional[str] = None
    Floor: Optional[str] = None
    Room_Number: Optional[str] = None
class HostelCreate(HostelBase): pass
class Hostel(HostelBase):
    model_config = ConfigDict(from_attributes=True)

class FacultyBase(BaseModel):
    Faculty_ID: str
    Faculty_Name: str
class FacultyCreate(FacultyBase): pass
class Faculty(FacultyBase):
    model_config = ConfigDict(from_attributes=True)