import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uthm/theme/app_colors.dart';

class VirtualIdPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const VirtualIdPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.brandPrimary,
                  const Color(0xFF6A1B9A).withOpacity(0.6),
                  colors.brandPrimary.withOpacity(0.8),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                          "My Virtual ID",
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: _buildGlassIdCard(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIdCard(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/logo-uthm-web.png',
                      height: 35,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, size: 35, color: Colors.white),
                    ),
                    Text(
                        "STUDENT ID",
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: const AssetImage('assets/me.jpg'),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                    userData['Name']?.toString().toUpperCase() ?? 'UNKNOWN',
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.brandPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                      userData['User_ID']?.toString() ?? '-',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: colors.brandPrimary, letterSpacing: 1)
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow("Faculty", userData['Faculty_ID']?.toString() ?? "-"),
                      const Divider(height: 20, color: Colors.black12),
                      _buildDetailRow("Course", userData['Programme_Name']?.toString() ?? "-"),
                      const Divider(height: 20, color: Colors.black12),
                      _buildDetailRow("Session Enroll", "2024/2025"),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.qr_code_2, size: 90, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text("Scan to Verify", style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(fontSize: 9, color: Colors.black54, fontWeight: FontWeight.w800, letterSpacing: 0.5)
        ),
        const SizedBox(height: 2),
        Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600, height: 1.2)
        ),
      ],
    );
  }
}