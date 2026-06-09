from pydantic import BaseModel, ConfigDict, EmailStr
from typing import Optional
from decimal import Decimal
from datetime import date
class StudentBase(BaseModel):
    Student_ID: str
    Programme_ID: str = None
class StudentCreate(StudentBase): pass
class Student(StudentBase):
    model_config = ConfigDict(from_attributes=True)

class FinanceAccountBase(BaseModel):
    Account_ID: str
    Student_ID: Optional[str] = None
    Total_Debit: Decimal = Decimal('0.00')
    Total_Credit: Decimal = Decimal('0.00')
class FinanceAccountCreate(FinanceAccountBase): pass
class FinanceAccount(FinanceAccountBase):
    model_config = ConfigDict(from_attributes=True)

class PaymentDetailBase(BaseModel):
    Payment_ID: str
    Account_ID: Optional[str] = None
    Item_Name: Optional[str] = None
    Amount: Optional[Decimal] = None
    Payment_Date: Optional[date] = None
    Status: Optional[str] = None
class PaymentDetailCreate(PaymentDetailBase): pass
class PaymentDetail(PaymentDetailBase):
    model_config = ConfigDict(from_attributes=True)