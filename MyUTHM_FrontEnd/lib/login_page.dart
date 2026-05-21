import 'dart:convert';
import 'package:http/http.dart' as http; // 确保在终端运行了: flutter pub add http
import 'package:flutter/material.dart';
import 'main.dart'; // 必须导入 main.dart 以使用 mainGlobalKey
import 'dart:io';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
void main() {
  // 👈 3. 在运行 App 之前，全局应用我们的信任规则
  HttpOverrides.global = MyHttpOverrides();

  runApp(const main());
}
class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  // 🚀 核心修改：将 _doLogin 改为异步函数，用于连接 Python 后端
  Future<void> _doLogin() async {
    final String matricNo = _userController.text.trim();
    final String password = _passController.text;

    // 1. 检查输入是否为空
    if (matricNo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Username and Password")),
      );
      return;
    }

    // 2. 显示 Loading 提示框（让界面看起来更专业）
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 3. 设置后端 API 地址
    // ⚠️ 如果使用 Android 模拟器，请保持 10.0.2.2
    // ⚠️ 如果使用真实手机测试，请改成你电脑的真实 WiFi IP (例如: http://192.168.1.100:5000/login)
    final String apiUrl = "https://10.0.2.2:5000/login";

    try {
      // 4. 发送 POST 请求到 Python (加入了 10秒超时限制！)
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "matric_no": matricNo,
          "password": password,
        }),
      ).timeout(
        const Duration(seconds: 10), // 👈 新增：如果 10 秒都没连上服务器，就抛出异常
        onTimeout: () {
          throw Exception("Connection timed out"); // 抛出异常，进入 catch 块关闭 Loading
        },
      );

      // 关闭 Loading 提示框
      if (mounted) Navigator.pop(context);

      // 5. 判断服务器返回的结果
      if (response.statusCode == 200) {
        // ✅ 登录成功！
        final responseData = jsonDecode(response.body);
        final String jwtToken = responseData['token']; // 获取密码学 Token

        print("🔐 成功拿到密码学 Token: $jwtToken"); // 演示时可以打开 Console 给教授看！

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Successful! Secured by Cryptography ✅"),
              backgroundColor: Colors.green,
            ),
          );

          // 跳转到你的 Main App
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainEntryPage(key: mainGlobalKey)),
          );
        }
      } else {
        // ❌ 账号或密码错误
        final responseData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${responseData['error']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 关闭 Loading 提示框
      if (mounted) Navigator.pop(context);

      // 🚨 网络错误提示
      print("网络连接失败: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connection failed. Is the Python server running?"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Color(0xFF0422A7)),
            const SizedBox(height: 40),
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Username (Matric No)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _doLogin,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0422A7)),
                child: const Text("LOGIN", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 下方原本的 LogoutPage 保持不变
// ---------------------------------------------------------
class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Do you want to quit this app?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              "Welcome back, Admin!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}