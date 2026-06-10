// 文件路径: lib/profile/components/logout_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uthm/theme/app_colors.dart'; // 👈 严格引用颜色库
import '../../main.dart'; // 引入以使用 mainGlobalKey

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Do you want to quit this app?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // 保持 18px 圆角
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭弹窗
              mainGlobalKey.currentState?.logout(); // 触发全局安全注销逻辑
            },
            child: Text("Yes", style: TextStyle(color: context.colors.error)), // 👈 使用颜色库的错误色
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55, // 统一按钮高度
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          "Log Out",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.error, // 👈 按钮背景使用颜色库的 error 颜色
          elevation: 0, // 扁平化风格
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // 18px 圆角
        ),
      ),
    );
  }
}