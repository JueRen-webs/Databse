import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uthm/theme/app_colors.dart';

class ProfileHelpers {

  static Future<void> launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }



  static BoxDecoration buildCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.colors.surface,

      borderRadius: BorderRadius.circular(18),

      border: Border.all(color: context.colors.borderColor, width: 0.5),
    );
  }


  static Widget buildSectionSubLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.brandPrimary)),
    );
  }


  static Widget buildInfoRow(BuildContext context, IconData icon, String label, String value, {VoidCallback? onTap}) {
    final colors = context.colors;
    Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: colors.brandPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: colors.brandPrimary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: colors.secondaryText)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onTap != null ? colors.brandPrimary : colors.primaryText,
                    decoration: onTap != null ? TextDecoration.underline : null,
                    decorationColor: colors.brandPrimary,
                  )),
            ],
          ),
        ),
        if (onTap != null) Icon(Icons.open_in_new, size: 16, color: colors.brandPrimary),
      ],
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: row);
    }
    return row;
  }


  static Widget buildContactCard(BuildContext context, {required String deptName, required String address, required String phone, required String fax, required String email, required String web}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.colors.cardAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.colors.borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(deptName, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: context.colors.primaryText)),
        const SizedBox(height: 8),
        buildContactRow(context, Icons.location_on, address),
        buildContactRow(context, Icons.phone, phone),
        buildContactRow(context, Icons.email, email),
      ]),
    );
  }


  static Widget buildContactRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: context.colors.brandPrimary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12, color: context.colors.primaryText))),
      ]),
    );
  }
}