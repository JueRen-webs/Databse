import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database_helper.dart';
import 'constants.dart';
import 'video_background.dart';
import 'campus_map.dart';
import 'emergency_contacts_page.dart';
import 'finance_page.dart';
import 'timetable_page.dart';
import 'vehicle_page.dart';
import 'course_page.dart';
import 'daily_timetable_widget.dart';
import '../theme/app_colors.dart';
import '../uthm_social_links.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kBackgroundColor,
      body: HomePageContent(),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  void initState() {
    super.initState();
  }

  String _getFormattedDate() {
    var now = DateTime.now();
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    List<String> weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return "${weekDays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}";
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  Widget _buildMenuIcon(IconData icon, String label, {VoidCallback? onTap}) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.brandPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: colors.brandPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              color: colors.primaryText,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const VideoBackground(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    stops: const [0.0, 0.55, 1.0],
                    colors: [
                      colors.brandPrimary,
                      colors.brandPrimary.withValues(alpha: 0.35),
                      colors.surface.withValues(alpha: 0.10),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getFormattedDate(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: colors.surface.withValues(alpha: 0.92),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black26,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${_getGreeting()} Lee Rou",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: colors.surface,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                  color: Colors.black45,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.30),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.surface.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon:
                            Icon(Icons.phone, size: 24, color: colors.surface),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EmergencyContactsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primaryText.withValues(alpha: 0.055),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.directions_bus_filled_outlined,
                            'Bus Tracking',
                            onTap: () async =>
                                _launchURL('https://uthm.katsana.com/'),
                          ),
                        ),
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.map_outlined,
                            'Campus Map',
                            onTap: () => showCampusMapMenu(context),
                          ),
                        ),
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.calendar_month_outlined,
                            'Timetable',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TimetablePage(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.attach_money,
                            'Finance',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FinancePage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.home_work_outlined,
                            'Hostel',
                            onTap: () => _launchURL(
                              'https://homs.uthm.edu.my/Start?ReturnUrl=%2F',
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.directions_car_filled_outlined,
                            'Vehicle',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VehiclePage(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.school_outlined,
                            'Course',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CoursePage(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.access_time,
                            'Reservation',
                            onTap: () => _launchURL(
                              'https://stars.uthm.edu.my/',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<StudentScheduleItem>>(
                future: DatabaseHelper.instance
                    .getStudentDailyTimetable(DatabaseHelper.currentUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primaryText.withValues(alpha: 0.055),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    );
                  }

                  final dailyItems = snapshot.data ?? [];
                  if (dailyItems.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primaryText.withValues(alpha: 0.055),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "No classes scheduled for today! 🎉",
                          style: GoogleFonts.inter(
                            color: colors.secondaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  return DailyTimetableCard(items: dailyItems);
                },
              ),
              const SizedBox(height: 16),
              const DueDateReminderDbCard(),
              const SizedBox(height: 40),
              const UthmSocialLinksRow(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}
