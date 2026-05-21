import mysql.connector

def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",      # XAMPP 默认用户名
        password="",      # XAMPP 默认密码为空
        database="myuthm_db"
    )