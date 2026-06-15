import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uthm/database_helper.dart';

class LecturerProfileTab extends StatelessWidget {
  const LecturerProfileTab({super.key, required this.sectionId});

  final String sectionId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DatabaseHelper.instance.getLecturerProfile(sectionId: sectionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final lecturer = snapshot.data ?? const <String, dynamic>{};
        final name = _value(lecturer['Name']);
        final staffId = _value(lecturer['User_ID']);
        final email = _value(lecturer['Email']);
        final phone = _value(lecturer['Phone']);
        final faculty = _value(lecturer['Faculty_ID']);

        return SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: 220,
              child: Stack(alignment: Alignment.topCenter, children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=2070&auto=format&fit=crop',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.pinkAccent,
                      backgroundImage: AssetImage('assets/me.jpg'),
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Staff ID: $staffId",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Email: $email",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 24),
                _item("Phone", phone),
                _item("Website", "-"),
                _item("Facebook", "-"),
                _item("Instagram", "-"),
                _item("Room", "-"),
                _item("Faculty", faculty),
                _item("Classroom Info", "-"),
                const SizedBox(height: 30),
              ]),
            ),
          ]),
        );
      },
    );
  }

  String _value(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? "-" : text;
  }

  Widget _item(String label, String value) {
    final displayValue = value.trim().isEmpty ? "-" : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        "$label: $displayValue",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
