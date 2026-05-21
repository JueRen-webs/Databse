import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uthm/theme/app_colors.dart';
import 'profile_helpers.dart';

class StudentDetailsCard extends StatelessWidget {
  const StudentDetailsCard({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      // Apple 规范：降低密度，加大内边距到 24
      padding: const EdgeInsets.all(24),
      decoration: ProfileHelpers.buildCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Student Details", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: colors.primaryText)),
          const SizedBox(height: 16),
          ProfileHelpers.buildInfoRow(context, Icons.domain, "Faculty", "FSKTM", onTap: () => ProfileHelpers.launchURL("https://fsktm.uthm.edu.my/")),
          Divider(height: 30, color: colors.borderColor, thickness: 0.5),
          ProfileHelpers.buildInfoRow(context, Icons.school, "Course", "Bachelor of Computer Science\n(Multimedia Computing)"),
          Divider(height: 30, color: colors.borderColor, thickness: 0.5),
          ProfileHelpers.buildInfoRow(context, Icons.email_outlined, "Email", "ai248888@student.uthm.edu.my"),
          Divider(height: 30, color: colors.borderColor, thickness: 0.5),
          ProfileHelpers.buildInfoRow(context, Icons.phone_iphone, "Phone", "+60 12-345 6789"),
        ],
      ),
    );
  }
}

class NextOfKinCard extends StatelessWidget {
  const NextOfKinCard({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: ProfileHelpers.buildCardDecoration(context),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), // 加大水平留白
          leading: Icon(Icons.group_outlined, color: colors.brandPrimary, size: 28),
          title: Text("Guardian Details", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: colors.primaryText)),
          childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24), // 加大内部留白
          children: [
            Divider(height: 1, color: colors.borderColor, thickness: 0.5),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: colors.cardAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.borderColor, width: 0.5)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Lee Kah", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: colors.primaryText)),
                    const SizedBox(height: 8),
                    ProfileHelpers.buildContactRow(context, Icons.supervised_user_circle, "Relationship: Guardian"),
                    ProfileHelpers.buildContactRow(context, Icons.phone, "+60 17-999 8888"),
                  ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactUsCard extends StatelessWidget {
  const ContactUsCard({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: ProfileHelpers.buildCardDecoration(context),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          leading: Icon(Icons.support_agent, color: colors.brandPrimary, size: 28),
          title: Text("Contact Us", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: colors.primaryText)),
          childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Divider(height: 1, color: colors.borderColor, thickness: 0.5),
            const SizedBox(height: 20),
            ProfileHelpers.buildContactCard(context, deptName: "Universiti Tun Hussein Onn Malaysia (UTHM)", address: "86400 Parit Raja Batu Pahat Johor\nMalaysia", phone: "+607-453 7000", fax: "+607-453 6337", email: "pro@uthm.edu.my", web: "http://www.uthm.edu.my"),
            const SizedBox(height: 16),
            ProfileHelpers.buildSectionSubLabel(context, "Postgraduate (Master & PhD)"),
            ProfileHelpers.buildContactCard(context, deptName: "Centre for Graduate Studies", address: "86400 Parit Raja Batu Pahat Johor", phone: "+607-453 7757 / 7509", fax: "+607-453 6111", email: "ps@uthm.edu.my", web: "http://cgs.uthm.edu.my"),
            const SizedBox(height: 16),
            ProfileHelpers.buildSectionSubLabel(context, "Undergraduate (Diploma & Degree)"),
            ProfileHelpers.buildContactCard(context, deptName: "Academic Management Office", address: "86400 Parit Raja Batu Pahat Johor", phone: "+607-453 7696", fax: "+607-453 6085", email: "pa@uthm.edu.my", web: "http://ppa.uthm.edu.my"),
            const SizedBox(height: 16),
            ProfileHelpers.buildSectionSubLabel(context, "International Student"),
            ProfileHelpers.buildContactCard(context, deptName: "International Office", address: "86400 Parit Raja Batu Pahat Johor", phone: "+607-453 8514 / 8515", fax: "+607-453 8516", email: "io@uthm.edu.my", web: "http://io.uthm.edu.my"),
          ],
        ),
      ),
    );
  }
}