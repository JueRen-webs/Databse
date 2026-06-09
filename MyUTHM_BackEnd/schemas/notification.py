from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime

class NotificationBase(BaseModel):
    Notification_ID: str
    Category: Optional[str] = None
    Title: Optional[str] = None
    URL: Optional[str] = None
    Created_Time: Optional[datetime] = None
class NotificationCreate(NotificationBase): pass
class Notification(NotificationBase):
    model_config = ConfigDict(from_attributes=True)

class ReminderBase(BaseModel):
    Reminder_ID: str
    User_ID: Optional[str] = None
    Reminder_Status_ID: Optional[str] = None
    Title: Optional[str] = None
    Comment: Optional[str] = None
    Due_Date: Optional[datetime] = None
class ReminderCreate(ReminderBase): pass
class Reminder(ReminderBase):
    model_config = ConfigDict(from_attributes=True)