from sqlalchemy import Column, Integer, String
from database import Base

class Student(Base):
    __tablename__ = "students"

    id           = Column(Integer, primary_key=True, index=True)
    matric_no    = Column(String, unique=True, index=True, nullable=False)
    full_name    = Column(String, nullable=False)
    faculty      = Column(String, nullable=False)
    course       = Column(String, nullable=False)
    email        = Column(String, nullable=False)
    phone        = Column(String)
    session_enroll = Column(String)

class NextOfKin(Base):
    __tablename__ = "next_of_kin"

    id           = Column(Integer, primary_key=True, index=True)
    student_id   = Column(Integer, nullable=False)
    name         = Column(String, nullable=False)
    relationship = Column(String, nullable=False)
    phone        = Column(String, nullable=False)

class AcademicRecord(Base):
    __tablename__ = "academic_records"

    id             = Column(Integer, primary_key=True, index=True)
    student_id     = Column(Integer, nullable=False)
    current_gpa    = Column(String)
    current_cpa    = Column(String)
    credits_obtained = Column(Integer)
    credits_total    = Column(Integer)
    outstanding_debt = Column(String)
    current_week     = Column(Integer)
    total_weeks      = Column(Integer)
