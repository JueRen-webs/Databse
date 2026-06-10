import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import '../theme/app_colors.dart';

Future<void> _launchCampusMapUrl(String urlString) async {
  final Uri url = Uri.parse(urlString);
  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  } catch (e) {
    debugPrint('Error launching URL: $e');
  }
}

void showCampusMapMenu(BuildContext context) {
  final colors = context.colors;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colors.primaryText.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Campus",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Navigate to your destination",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: 24),
                _buildCampusMapOption(
                  context,
                  "Main Campus (Parit Raja)",
                  Icons.business_rounded,
                  kMapLinkMain,
                ),
                const SizedBox(height: 12),
                _buildCampusMapOption(
                  context,
                  "Pagoh Campus",
                  Icons.school_rounded,
                  kMapLinkPagoh,
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack).value,
        child: child,
      );
    },
  );
}

Widget _buildCampusMapOption(
  BuildContext context,
  String title,
  IconData icon,
  String link,
) {
  final colors = context.colors;

  return InkWell(
    onTap: () {
      Navigator.pop(context);
      _launchCampusMapUrl(link);
    },
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.brandPrimary.withValues(alpha: 0.14),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(icon, color: colors.brandPrimary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.primaryText,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: colors.secondaryText,
          ),
        ],
      ),
    ),
  );
}

// Legacy map menu (used in HomePageContent)
Future<void> launchLegacyMapUrl(String urlString) async {
  final Uri url = Uri.parse(urlString);
  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  } catch (e) {
    debugPrint('Error launching URL: $e');
  }
}

void showLegacyMapMenu(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Select Campus",
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 8),
                Text("Navigate to your destination",
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 24),
                buildLegacyMinimalMapOption(
                    context,
                    "Main Campus (Parit Raja)",
                    Icons.business_rounded,
                    Colors.redAccent,
                    kMapLinkMain),
                const SizedBox(height: 12),
                buildLegacyMinimalMapOption(context, "Pagoh Campus",
                    Icons.school_rounded, Colors.blueAccent, kMapLinkPagoh),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale:
            CurvedAnimation(parent: anim1, curve: Curves.easeOutBack).value,
        child: child,
      );
    },
  );
}

Widget buildLegacyMinimalMapOption(BuildContext context, String title,
    IconData icon, Color accentColor, String link) {
  return InkWell(
    onTap: () {
      Navigator.pop(context);
      launchLegacyMapUrl(link);
    },
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Colors.grey.shade400),
        ],
      ),
    ),
  );
}
