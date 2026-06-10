import 'package:flutter/material.dart';
import 'main.dart'; // 必须导入 main.dart 以使用 mainGlobalKey
import 'theme/app_colors.dart';
import 'database_helper.dart';

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
      // Try to talk to the database
      var user = await DatabaseHelper.instance.loginWithExistingAccount(username, password);

      // VERY IMPORTANT: Check if the widget is still on screen before updating UI
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        print("Login Success: ${user['Name']}, Role: ${user['Role']}");

        DashboardRole currentRole;
        if (user['Role'] == 'Student') {
          currentRole = DashboardRole.student;
        } else {
          currentRole = DashboardRole.lecturer;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainEntryPage(
              key: mainGlobalKey,
              role: currentRole,
            ),
          ),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Matric No or Password')),
        );
      }
    } catch (e) {
      // IF SOMETHING CRASHES, CATCH IT HERE!
      if (!mounted) return;

      setState(() {
        _isLoading = false; // Stop the spinner!
      });

      // Print the error to the console and show it on the screen
      print("❌ Database CRASH: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
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