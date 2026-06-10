import 'package:flutter/material.dart';

import 'lecturer_home_header.dart';
import 'lecturer_home_sections.dart';
import 'theme/app_colors.dart';
import 'uthm_social_links.dart';

class LecturerDashboardPage extends StatelessWidget {
  const LecturerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Container(
      color: colors.background,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 24 + bottomSafeArea),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LecturerHomeHeader(),
              Padding(
                padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Column(
                  children: [
                    LecturerFunctionPanel(),
                    SizedBox(height: 16),
                    LecturerScheduleCard(),
                    SizedBox(height: 16),
                    LecturerDueReminderCard(),
                    SizedBox(height: 40),
                    UthmSocialLinksRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
