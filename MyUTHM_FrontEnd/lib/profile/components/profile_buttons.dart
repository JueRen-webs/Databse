import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uthm/theme/app_colors.dart';
import '../../main.dart';
import '../academic_calendar_page.dart';

class AcademicCalendarButton extends StatelessWidget {
  const AcademicCalendarButton({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AcademicCalendarPage()));
        },
        icon: Icon(Icons.calendar_month, color: colors.brandPrimary),
        label: Text("Academic Calendar", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colors.brandPrimary, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.surface,
          elevation: 0, // Apple: 扁平化，不要阴影
          side: BorderSide(color: colors.brandPrimary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // 18px 圆角
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Do you want to quit this app?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // 弹窗也保持 18px 圆角
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              mainGlobalKey.currentState?.logout();
            },
            child: Text("Yes", style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55, // 高度统一
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text("Log Out", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.error,
          elevation: 0, // Apple: 扁平化，不要阴影
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // 18px 圆角
        ),
      ),
    );
  }
}