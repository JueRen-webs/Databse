import 'package:flutter/material.dart';
import 'package:uthm/theme/app_colors.dart';

import 'profile/components/profile_buttons.dart';
import 'profile/components/profile_cards.dart';
import 'profile/components/profile_widgets.dart';

class LecturerProfilePage extends StatelessWidget {
  const LecturerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
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
            const SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25),
                    FlatIdentityHeader(
                      name: "HANAYANTI BINTI HAFIT",
                      idLabel: "Staff ID: 00888",
                      showAvatarImage: false,
                    ),
                    SizedBox(height: 15),
                    WeekGridProgress(),
                    SizedBox(height: 12),
                    StaffDetailsCard(),
                    SizedBox(height: 12),
                    NextOfKinCard(),
                    SizedBox(height: 12),
                    LecturerContactUsCard(),
                    SizedBox(height: 12),
                    AcademicCalendarButton(),
                    SizedBox(height: 12),
                    LogoutButton(),
                    SizedBox(height: 40),
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
      ),
    );
  }
}
