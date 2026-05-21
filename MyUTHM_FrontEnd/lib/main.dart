import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 引入你的各个页面
import 'home_page.dart';
import 'academic_page.dart';
import 'scan_page.dart';
import 'notification_page.dart';
import 'profile/profile_page.dart';
import 'splash_page.dart';
import 'login_page.dart';
import 'theme/app_colors.dart'; // 引入颜色库
import 'dart:io';
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const DigitalClassroomApp());
}

final GlobalKey<MainEntryPageState> mainGlobalKey =
GlobalKey<MainEntryPageState>();

class DigitalClassroomApp extends StatefulWidget {
  const DigitalClassroomApp({super.key});

  @override
  State<DigitalClassroomApp> createState() => _DigitalClassroomAppState();
}

class _DigitalClassroomAppState extends State<DigitalClassroomApp> {
  // 默认跟随系统主题
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

      // 亮色主题配置
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        extensions: [lightColors],
        scaffoldBackgroundColor: lightColors.background,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),

      // 暗色主题配置
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        extensions: [darkColors],
        scaffoldBackgroundColor: darkColors.background,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),

      themeMode: _themeMode,
      home: const SplashPage(),
    );
  }
}

class MainEntryPage extends StatefulWidget {
  const MainEntryPage({super.key});

  @override
  State<MainEntryPage> createState() => MainEntryPageState();
}

class MainEntryPageState extends State<MainEntryPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const AcademicPage(),
    const ScanPage(),
    const NotificationPage(),
    const ProfilePage(),
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
      _selectedIndex = index;
    });
  }

  void switchToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 这里的 colors 会根据当前是白天还是黑夜自动切换
    final colors = context.colors;

    if (_selectedIndex == 2) {
      return const ScanPage();
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
          child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
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
            const SizedBox(width: 40),
            _buildNavItem(Icons.notifications_none, 'Notification', 3),
            _buildNavItem(Icons.person_outline, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
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
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}