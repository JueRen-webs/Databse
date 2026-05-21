# 文件路径: main.py
from flask import Flask
from flask_cors import CORS
import login # 👈 导入刚刚编写的身份验证蓝图

app = Flask(__name__)
CORS(app)

# 🔐 JWT 数字签名密钥 (保持全局配置)
app.config['SECRET_KEY'] = 'uthm_super_secret_crypto_key_2026'

# 🚀 核心：注册蓝图
# 注册后，auth_bp 里面定义的所有路由（如 /login）都会自动挂载到主服务上
app.register_blueprint(login.auth_bp)

if __name__ == '__main__':
    # 加上 ssl_context='adhoc' 自动生成 HTTPS 证书
    app.run(debug=True, host='0.0.0.0', port=5000, ssl_context='adhoc')