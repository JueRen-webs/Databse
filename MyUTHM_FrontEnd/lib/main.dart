import 'package:google_fonts/google_fonts.dart';

import 'home/home_page.dart';
import 'lecturer_dashboard_page.dart';
import 'academic_page.dart';
import 'lecturer_academic_page.dart';
import 'scan_page.dart';
import 'notification_page.dart';
import 'profile/profile_page.dart';
import 'lecturer_profile_page.dart';
import 'splash_page.dart';
import 'login_page.dart';
import 'theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  print("============= [MyUTHM] App Initializing =============");

  try {
    print("Connecting Database");

    await DatabaseHelper.instance.database;
    print("Database Load Successfully");
  } catch (e, stacktrace) {
    print("Database Initialization Error $e");
    print("Message: $stacktrace");
  }

  print("============= Starting =============");
  runApp(const DigitalClassroomApp());
}

final GlobalKey<MainEntryPageState> mainGlobalKey =
    GlobalKey<MainEntryPageState>();

enum DashboardRole { student, lecturer }

class DigitalClassroomApp extends StatefulWidget {
  const DigitalClassroomApp({super.key});

  @override
  State<DigitalClassroomApp> createState() => _DigitalClassroomAppState();
}

class _DigitalClassroomAppState extends State<DigitalClassroomApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Classroom',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        extensions: const [lightColors],
        scaffoldBackgroundColor: lightColors.background,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        extensions: const [darkColors],
        scaffoldBackgroundColor: darkColors.background,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      themeMode: _themeMode,
      home: const SplashPage(),
    );
  }
}

class MainEntryPage extends StatefulWidget {
  const MainEntryPage({super.key, this.role = DashboardRole.student});

  final DashboardRole role;

  @override
  State<MainEntryPage> createState() => MainEntryPageState();
}

class MainEntryPageState extends State<MainEntryPage> {
  int _selectedIndex = 0;
  int _lastNonScanIndex = 0;

  List<Widget> get _pages => [
        widget.role == DashboardRole.lecturer
            ? const LecturerDashboardPage()
            : const HomePageContent(),
        widget.role == DashboardRole.lecturer
            ? const LecturerAcademicPage()
            : const AcademicPage(),
        const ScanPage(),
        const NotificationPage(),
        widget.role == DashboardRole.lecturer
            ? const LecturerProfilePage()
            : const ProfilePage(),
      ];

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 2 && _selectedIndex != 2) {
        _lastNonScanIndex = _selectedIndex;
      } else if (index != 2) {
        _lastNonScanIndex = index;
      }
      _selectedIndex = index;
    });
  }

  void switchToTab(int index) {
    setState(() {
      if (index == 2 && _selectedIndex != 2) {
        _lastNonScanIndex = _selectedIndex;
      } else if (index != 2) {
        _lastNonScanIndex = index;
      }
      _selectedIndex = index;
    });
  }

  void closeScanPage() {
    setState(() {
      _selectedIndex = _lastNonScanIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_selectedIndex == 2) {
      return ScanPage(onClose: closeScanPage);
    }

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: false,
      body: _pages[_selectedIndex],
      floatingActionButton: SizedBox(
        width: 75,
        height: 75,
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(2),
          backgroundColor: colors.brandPrimary,
          shape: const CircleBorder(),
          elevation: 4,
          child:
              const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 70,
        color: colors.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.menu_book, 'Academic', 1),
            SizedBox(
              width: 54,
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'Scan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _buildNavItem(Icons.notifications_none, 'Notifications', 3),
            _buildNavItem(Icons.person_outline, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    String? badgeText,
  }) {
    final isSelected = _selectedIndex == index;
    final color =
        isSelected ? context.colors.brandPrimary : context.colors.secondaryText;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 26),
                if (badgeText != null)
                  Positioned(
                    right: -8,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.error,
                        borderRadius: BorderRadius.circular(99),
                        border:
                            Border.all(color: context.colors.surface, width: 1),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: label.length > 10 ? 9 : 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
