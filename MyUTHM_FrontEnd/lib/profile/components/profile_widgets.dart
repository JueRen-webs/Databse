import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uthm/theme/app_colors.dart';
import '../virtual_id_page.dart';

class FlatIdentityHeader extends StatelessWidget {
  final Map<String, dynamic> userData;

  const FlatIdentityHeader({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withOpacity(0.2),
              border: Border.all(
                color: colors.surface.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: colors.borderColor,
              backgroundImage: const AssetImage('assets/me.jpg'),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            userData['Name']?.toString().toUpperCase() ?? 'UNKNOWN',
            style: GoogleFonts.poppins(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "(Matric No: ${userData['User_ID'] ?? '-'})",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VirtualIdPage(userData: userData)),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.surface.withOpacity(0.35),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner, size: 15, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    "My Virtual ID",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsButton extends StatefulWidget {
  const SettingsButton({super.key});
  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface,
          border: Border.all(color: colors.borderColor, width: 0.5),
        ),
        child: Icon(
          Icons.settings_outlined,
          color: colors.primaryText,
          size: 24,
        ),
      ),
    );
  }
}

class WeekGridProgress extends StatelessWidget {
  const WeekGridProgress({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const int totalWeeks = 14; const int currentWeek = 8;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Week Progress", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: colors.primaryText, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: colors.brandPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text("Week $currentWeek / $totalWeeks", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colors.brandPrimary, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (int i = 0; i < totalWeeks; i++) ...[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: i < currentWeek ? colors.brandPrimary : colors.borderColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                if (i < totalWeeks - 1) const SizedBox(width: 5),
              ]
            ],
          ),
        ],
      ),
    );
  }
}

class StatsRowBar extends StatelessWidget {
  final Map<String, dynamic> userData;

  const StatsRowBar({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(context, "Current\nCPA", userData['CGPA']?.toStringAsFixed(2) ?? "0.00"),
        const SizedBox(width: 12),
        _buildStatItem(context, "Current\nCGPA", userData['CCPA']?.toStringAsFixed(2) ?? "0.00"),
        const SizedBox(width: 12),
        _buildStatItem(context, "Obtained\nCredit", "${userData['Obtained_Credits'] ?? '0'}/122"),
        const SizedBox(width: 12),
        _buildStatItem(context, "Outstanding\nDebt", "RM 0.00"),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, {String? subLabel}) {
    final colors = context.colors;
    final bool isLongText = value.length > 6;

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isLongText ? 12 : 12, horizontal: 4),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.borderColor, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  height: 1.1,
                  color: colors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              SizedBox(height: isLongText ? 2 : 6),
              Expanded(
                child: Center(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: isLongText ? 13 : 16,
                      height: isLongText ? 1.1 : null,
                      fontWeight: FontWeight.bold,
                      color: colors.primaryText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: isLongText ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (subLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  subLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: colors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}