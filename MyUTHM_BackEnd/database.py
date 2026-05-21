import mysql.connector
from werkzeug.security import generate_password_hash

# 连接到 XAMPP MySQL (XAMPP 默认账号是 root，密码是空的)
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="myuthm_db"
)
cursor = db.cursor()

# 你的学号和想要设置的密码
matric_no = "admin"
raw_password = "1234"
name = "Test"
faculty = "Unknown"

# 🔐 核心：把明文密码变成 Hash 乱码！
hashed_password = generate_password_hash(raw_password)

# 插入到数据库
sql = "INSERT INTO users (matric_no, password_hash, name, faculty) VALUES (%s, %s, %s, %s)"
val = (matric_no, hashed_password, name, faculty)

try:
    cursor.execute(sql, val)
    db.commit()
    print(f"✅ 成功将用户 {matric_no} 注册到 MySQL 数据库！")
    print(f"数据库里存储的密码是安全的 Hash 值: {hashed_password}")
except mysql.connector.Error as err:
    print(f"❌ 发生错误: {err}")

cursor.close()
db.close()