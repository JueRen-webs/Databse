import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uthm/theme/app_colors.dart';
import 'academic_calendar_page.dart';

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