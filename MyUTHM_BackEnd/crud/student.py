import sqlite3
from schemas.student import StudentCreate, PaymentDetailCreate

# 核心 JOIN 查询：Flutter 个人中心需要展示：学生基本账号信息 + 院系名称 + 学分绩点
def get_student_complete_profile(db: sqlite3.Connection, student_id: str) -> dict | None:
    cursor = db.cursor()
    query = """
        SELECT * FROM Students WHERE User_ID = ??
    """
    cursor.execute(query, (student_id,))
    row = cursor.fetchone()
    return dict(row) if row else None

def create_student_profile(db: sqlite3.Connection, student: StudentCreate) -> dict:
    cursor = db.cursor()
    cursor.execute(
        """
        INSERT INTO Students (Student_ID, Obtained_Credits, CGPA, CCPA, Faculty_ID)
        VALUES (?, ?, ?, ?, ?)
        """,
        (student.Student_ID, student.Obtained_Credits, float(student.CGPA), float(student.CCPA), student.Faculty_ID)
    )
    db.commit()
    return get_student_complete_profile(db, student.Student_ID)

# 核心商业逻辑：记录一笔学生缴费，流水成功后自动更新 Finance_Accounts 主表的已付额 (Total_Credit)
def process_student_payment(db: sqlite3.Connection, payment: PaymentDetailCreate) -> dict:
    cursor = db.cursor()

    # 1. 写入缴费明细表
    cursor.execute(
        """
        INSERT INTO Payment_Details (Payment_ID, Account_ID, Item_Name, Amount, Payment_Date, Status)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (payment.Payment_ID, payment.Account_ID, payment.Item_Name, float(payment.Amount),
         payment.Payment_Date.strftime("%Y-%m-%d") if payment.Payment_Date else None, payment.Status)
    )

    # 2. 商业对账逻辑：如果状态是已支付(Paid/Successful)，自动累加主账户的 Total_Credit
    if payment.Status in ["Paid", "Successful", "Success"]:
        cursor.execute(
            """
            UPDATE Finance_Accounts 
            SET Total_Credit = Total_Credit + ? 
            WHERE Account_ID = ?
            """,
            (float(payment.Amount), payment.Account_ID)
        )

    db.commit()
    return {"success": True, "message": "Payment records generated and balance synchronized"}

def get_student_finance_statement(db: sqlite3.Connection, student_id: str) -> dict | None:
    cursor = db.cursor()
    cursor.execute("SELECT * FROM Finance_Accounts WHERE Student_ID = ?", (student_id,))
    account = cursor.fetchone()
    if not account:
        return None

    # 联查账单明细
    cursor.execute("SELECT * FROM Payment_Details WHERE Account_ID = ?", (account["Account_ID"],))
    payments = [dict(row) for row in cursor.fetchall()]

    result = dict(account)
    result["payment_details"] = payments
    return result