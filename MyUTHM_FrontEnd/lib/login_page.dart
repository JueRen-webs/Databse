import 'package:flutter/material.dart';
import 'dart:convert'; // 用于 JSON 解析
import 'package:http/http.dart' as http; // 引入 http 包
import 'main.dart'; // 必须导入 main.dart 以使用 mainGlobalKey
import 'theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; // 添加加载状态

  // 将后端的 URL 定义为常量
  // 注意：如果你使用 Android 模拟器测试，请使用 10.0.2.2 替代 localhost 或 127.0.0.1
  // 如果是真机或 Web 测试，请填入你的电脑局域网 IP (例如 192.168.x.x)
  final String apiUrl = "http://localhost:8000/users/login";

  Future<void> _doLogin() async {
    final username = _userController.text.trim().toUpperCase();
    final password = _passController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter username and password")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 发送 POST 请求到 FastAPI 后端
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": username,        // 👈 改成 user_id
          "password_hash": password,  // 👈 改成 password_hash
        }),
      );

      // 检查 HTTP 状态码
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // 假设你的后端返回类似 {"role": "student"} 或 {"role": "lecturer"}
        final String? userRole = responseData['role'];

        DashboardRole? role;
        if (userRole?.toLowerCase() == "student") {
          role = DashboardRole.student;
        } else if (userRole?.toLowerCase() == "lecturer") {
          role = DashboardRole.lecturer;
        }

        if (role != null) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainEntryPage(
                key: mainGlobalKey,
                role: role!, // 这里使用的是从后端获取并转换的 role
              ),
            ),
          );
        } else {
          _showError("Invalid role received from server.");
        }
      } else {
        // 处理密码错误或账号不存在 (假设后端返回 400/401/404)
        final errorData = jsonDecode(response.body);
        _showError(errorData['detail'] ?? "Username or Password incorrect");
      }
    } catch (e) {
      // 处理网络错误 (例如后端没开、IP不对)
      _showError("Network error. Please check if backend is running.");
      print("Login Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 80, color: colors.brandPrimary),
            const SizedBox(height: 40),
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                  labelText: "Username", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  color: colors.secondaryText,
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _doLogin,
                style: ElevatedButton.styleFrom(
                    backgroundColor: colors.brandPrimary),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("LOGIN", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}