# routers/students.py
from fastapi import APIRouter, Depends, HTTPException
import sqlite3
from database import get_db
import crud.student as crud
from schemas.student import StudentCreate, PaymentDetailCreate

router = APIRouter(prefix="/students", tags=["Student & Finance"])

@router.post("")
def create_student(student: StudentCreate, db: sqlite3.Connection = Depends(get_db)):
    # 扩展学生档案表
    try:
        return crud.create_student_profile(db, student)
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=400, detail="Failed to create profile. Ensure User ID exists and is unique.")

@router.get("/{student_id}/profile")
def get_student_profile(student_id: str, db: sqlite3.Connection = Depends(get_db)):
    profile = crud.get_student_complete_profile(db, student_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Student profile not found")
    return profile

@router.get("/{student_id}/finance")
def get_finance_statement(student_id: str, db: sqlite3.Connection = Depends(get_db)):
    statement = crud.get_student_finance_statement(db, student_id)
    if not statement:
        raise HTTPException(status_code=404, detail="Finance account not found for this student")
    return statement

@router.post("/payments/pay")
def pay_student_bill(payment: PaymentDetailCreate, db: sqlite3.Connection = Depends(get_db)):
    # 触发内部带 Finance_Accounts 主表同步累加余额的对账逻辑
    result = crud.process_student_payment(db, payment)
    return result