import 'package:flutter/material.dart';
import 'package:uthm/theme/app_colors.dart';
import 'database_helper.dart';
import 'logout_page.dart';
import 'profile/academic_calender_page/academic_calendar_buttons.dart';
import 'profile/components/profile_cards.dart';
import 'profile/components/profile_widgets.dart';

class LecturerProfilePage extends StatelessWidget {
  const LecturerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: DatabaseHelper.instance.getLecturerProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colors.brandPrimary),
            );
          }

          final userData = snapshot.data ??
              {
                'User_ID': DatabaseHelper.currentUserId.isEmpty
                    ? '-'
                    : DatabaseHelper.currentUserId,
                'Name': '-',
                'Email': '-',
                'Phone': '-',
                'Role': 'Lecturer',
                'Faculty_ID': '-',
              };

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -500,
                  left: 0,
                  right: 0,
                  height: 500,
                  child: Container(color: colors.brandPrimary),
                ),
                Container(
                  height: 290,
                  decoration: BoxDecoration(
                    color: colors.brandPrimary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        FlatIdentityHeader(userData: userData),
                        const SizedBox(height: 15),
                        const WeekGridProgress(),
                        const SizedBox(height: 12),
                        StaffDetailsCard(userData: userData),
                        const SizedBox(height: 12),
                        const NextOfKinCard(),
                        const SizedBox(height: 12),
                        const LecturerContactUsCard(),
                        const SizedBox(height: 12),
                        const AcademicCalendarButton(),
                        const SizedBox(height: 12),
                        const LogoutButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 20,
                  child: const SettingsButton(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
