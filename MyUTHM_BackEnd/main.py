from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.security import check_password_hash
import mysql.connector
import jwt
import datetime
import db_connection;

app = Flask(__name__)
CORS(app)

# 🔐 JWT 数字签名密钥 (Authenticity)
app.config['SECRET_KEY'] = 'uthm_super_secret_crypto_key_2026'


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    matric_no = data.get('matric_no')
    password = data.get('password')

    if not matric_no or not password:
        return jsonify({"error": "Missing Matric No or Password"}), 400

    try:
        # 1. 连接 MySQL 数据库
        db = db_connection.get_db_connection()
        # dictionary=True 可以让结果变成字典格式，方便读取
        cursor = db.cursor(dictionary=True)

        # 2. 从数据库中寻找这个学号
        cursor.execute("SELECT * FROM users WHERE matric_no = %s", (matric_no,))
        user = cursor.fetchone()

        # 3. 密码学验证：检查找到的用户，并对比 Hash 密码
        if user and check_password_hash(user['password_hash'], password):

            # 4. 验证成功！颁发 JWT 令牌
            token = jwt.encode({
                'user': user['matric_no'],
                'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
            }, app.config['SECRET_KEY'], algorithm='HS256')

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
        # 确保每次请求完都关闭数据库连接
        if 'cursor' in locals(): cursor.close()
        if 'db' in locals(): db.close()

if __name__ == '__main__':
    # 加上 ssl_context='adhoc'，Flask 会自动为你生成临时的 HTTPS 证书！
    app.run(debug=True, host='0.0.0.0', port=5000, ssl_context='adhoc')