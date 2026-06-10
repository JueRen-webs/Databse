import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// 各功能页面
import 'constants.dart';
import 'video_background.dart';
import 'campus_map.dart';
import 'emergency_contacts_page.dart';
import 'finance_page.dart';
import 'timetable_page.dart';
import 'hostel_page.dart';
import 'complaint_page.dart';
import 'vehicle_page.dart';
import 'course_page.dart';
import 'reservation_page.dart';
import 'daily_timetable_widget.dart';
import '../theme/app_colors.dart';
import '../uthm_social_links.dart';

// ==========================================================
// 1. 主屏幕容器 (HomeScreen)
// ==========================================================
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

// ==========================================================
// 2. 主页内容 (HomePageContent)
// ==========================================================
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  // 每日课表数据
  final List<StudentScheduleItem> _todaySchedule = const [
    StudentScheduleItem(
      start: '8:00 AM',
      end: '10:00 AM',
      title: 'Data Structures',
      location: 'FSKTM BS1',
    ),
    StudentScheduleItem(
      start: '2:00 PM',
      end: '4:00 PM',
      title: 'Human Computer Interaction',
      location: 'FSKTM BS1',
    ),
    StudentScheduleItem(
      start: '4:00 PM',
      end: '6:00 PM',
      title: 'Operating Systems',
      location: 'FSKTM BS1',
    ),
  ];

  // 提醒事项数据
  List<Map<String, dynamic>> reminders = [
    {
      "title": "Sad Test",
      "date": "27/02",
      "comment": "F2 Ground Floor",
      "daysLeft": 2,
      "color": Colors.orange,
    },
    {
      "title": "Math Quiz",
      "date": "25/02",
      "comment": "Online Submission",
      "daysLeft": 1,
      "color": Colors.red,
    },
    {
      "title": "History Proj",
      "date": "15/03",
      "comment": "Main Hall",
      "daysLeft": 7,
      "color": Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    reminders.sort((a, b) {
      List<String> partsA = a['date'].split('/');
      List<String> partsB = b['date'].split('/');
      int dayA = int.parse(partsA[0]);
      int monthA = int.parse(partsA[1]);
      int dayB = int.parse(partsB[0]);
      int monthB = int.parse(partsB[1]);
      if (monthA != monthB) {
        return monthA.compareTo(monthB);
      } else {
        return dayA.compareTo(dayB);
      }
    });
  }

  String _getFormattedDate() {
    var now = DateTime.now();
    List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    List<String> weekDays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
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

  // ----------------------------------------------------------
  // Menu Icon Widget
  // ----------------------------------------------------------
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

  // ----------------------------------------------------------
  // Build
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── 顶部 Hero Header ──────────────────────────────────
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
                    // 左侧：日期 + 问候语
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFormattedDate(),
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

                    // 右侧：紧急联系人按钮
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
                        icon: Icon(Icons.phone, size: 24, color: colors.surface),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmergencyContactsPage(),
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

        // ── 下方内容区域 ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 菜单区域 ────────────────────────────────────
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
                    // 第一行
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
                    // 第二行
                    Row(
                      children: [
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.home_work_outlined,
                            'Hostel',
                            onTap: () => showHostelMenu(context),
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
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReservationPage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Daily Timetable (来自 daily_timetable_widget.dart) ──
              DailyTimetableCard(items: _todaySchedule),

              const SizedBox(height: 16),

              // ── Due Date Reminder (来自 daily_timetable_widget.dart) ──
              DueDateReminderCard(reminders: reminders),

              const SizedBox(height: 40),

              // ── 社交链接 ────────────────────────────────────
              const UthmSocialLinksRow(),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}
