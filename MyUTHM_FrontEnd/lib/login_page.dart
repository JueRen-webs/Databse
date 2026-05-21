// 文件路径: lib/login_page.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:uthm/theme/app_colors.dart'; // 👈 1. 核心新增：引入你的全局颜色库
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  // 核心注销/登录异步函数，用于连接 Python 后端
  Future<void> _doLogin() async {
    final String matricNo = _userController.text.trim();
    final String password = _passController.text;

    if (matricNo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Username and Password")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final String apiUrl = "https://10.0.2.2:5000/login";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "matric_no": matricNo,
          "password": password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Connection timed out");
        },
      );

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String jwtToken = responseData['token'];

        print("🔐 成功拿到密码学 Token: $jwtToken");

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainEntryPage(key: mainGlobalKey)),
          );
        }
      } else {
        final responseData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${responseData['error']}"),
              backgroundColor: context.colors.error, // 👈 2. 这里的提示框背景色也可以直接联动颜色库的 error
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
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
    // 👈 3. 核心修改：在 build 方法内获取全局颜色实例
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background, // 👈 4. 让登录页背景色也跟随主题库
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 👈 5. 核心修改：顶部的学校 Icon 颜色改为主品牌色
            Icon(Icons.school, size: 80, color: colors.brandPrimary),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.brandPrimary, // 👈 6. 核心修改：登录按钮背景色改为颜色库的 brandPrimary
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // 保持全校统一的 18px 圆角
                ),
                child: const Text("LOGIN", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}