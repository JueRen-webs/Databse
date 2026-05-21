# 文件路径: routes/auth.py
from flask import Blueprint, request, jsonify, current_app
from werkzeug.security import check_password_hash
import mysql.connector
import jwt
import datetime
from db_connection import get_db_connection # 👈 导入第一步提取出来的连接函数

# 🔐 创建身份验证蓝图
auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    matric_no = data.get('matric_no')
    password = data.get('password')

    if not matric_no or not password:
        return jsonify({"error": "Missing Matric No or Password"}), 400

    try:
        # 1. 连接 MySQL 数据库
        db = get_db_connection()
        cursor = db.cursor(dictionary=True)

        # 2. 从数据库中寻找这个学号
        cursor.execute("SELECT * FROM users WHERE matric_no = %s", (matric_no,))
        user = cursor.fetchone()

        # 3. 密码学验证
        if user and check_password_hash(user['password_hash'], password):
            # 4. 验证成功！颁发 JWT 令牌 (从 current_app 获取密钥)
            token = jwt.encode({
                'user': user['matric_no'],
                'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
            }, current_app.config['SECRET_KEY'], algorithm='HS256')

            return jsonify({
                "message": "Login Successful",
                "token": token,
                "user_data": {
                    "name": user['name'],
                    "matric_no": user['matric_no'],
                    "faculty": user['faculty']
                }
            }), 200
        else:
            return jsonify({"error": "Invalid Matric No or Password"}), 401

    except mysql.connector.Error as err:
        print(f"Database Error: {err}")
        return jsonify({"error": "Internal Server Error"}), 500

    finally:
        # 确保关闭连接
        if 'cursor' in locals(): cursor.close()
        if 'db' in locals(): db.close()