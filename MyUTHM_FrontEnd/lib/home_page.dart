import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

// 引入第二个文件
import 'home_page2.dart'; 

// 定义颜色常量
const Color kPrimaryBlue = Color(0xFF0025CC);
const Color kBackgroundColor = Color(0xFFF4F6FC);
const Color kBorderColor = Colors.black; 

// 课程表蓝色系配色
const Color kTimetableHeaderColor = Color(0xFFBBDEFB); 
const Color kTimetableCellColor = Color(0xFFE3F2FD);    

// 定义跳转链接常量
const String kMapLinkMain = 'https://www.google.com/maps/@1.8583141,103.0810745,16z?entry=ttu&g_ep=EgoyMDI1MTIwNy4wIKXMDSoKLDEwMDc5MjA3M0gBUAM%3D'; // Main Campus Link
const String kMapLinkPagoh = 'https://www.google.com/maps/search/UTHM+Pagoh'; // Pagoh Campus Link
const String kFinancePaymentLink = 'https://epayment.uthm.edu.my';

// 课表用的其他 Map Link
const String kMapLinkA = 'https://www.google.com/maps/place/%E6%95%A6%E5%A4%A7%E7%94%B5%E8%84%91%E7%A7%91%E5%AD%A6%E5%AD%A6%E9%99%A2/@1.8604238,103.0818436,17z/data=!3m1!4b1!4m6!3m5!1s0x31d05eaa8065ca25:0x8a27d9f8074a220!8m2!3d1.8604238!4d103.0844185!16s%2Fg%2F11clgh1_b2?entry=ttu&g_ep=EgoyMDI1MTIwNy4wIKXMDSoKLDEwMDc5MjA2N0gBUAM%3D';
const String kMapLinkB = 'https://www.google.com/maps/place/BLOK+B6/@1.8555161,103.0864496,18z/data=!4m6!3m5!1s0x31d05faf83d8ea07:0x126fb15625e89830!8m2!3d1.8555164!4d103.0872579!16s%2Fg%2F11kkyjs0nq?entry=ttu&g_ep=EgoyMDI1MTIwNy4wIKXMDSoKLDEwMDc5MjA2N0gBUAM%3D';
const String kMapLinkC = 'www.google.com/maps/place/%E9%A9%AC%E6%9D%A5%E8%A5%BF%E4%BA%9A%E6%95%A6%E8%83%A1%E5%85%88%E7%BF%81%E5%A4%A7%E5%AD%A6/@1.8572653,103.0807981,17z/data=!4m6!3m5!1s0x31d05eaa459d0ab9:0x495f817bef16f0a1!8m2!3d1.8572606!4d103.0820799!16zL20vMGdyMXl6?entry=ttu&g_ep=EgoyMDI1MTIwNy4wIKXMDSoKLDEwMDc5MjA2N0gBUAM%3D';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

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
  // 提醒事项数据
  List<Map<String, dynamic>> reminders = [
    {
      "title": "Sad Test",
      "date": "27/02",
      "comment": "F2 Ground Floor",
      "color": Colors.orange,
    },
    {
      "title": "Math Quiz",
      "date": "25/02",
      "comment": "Online Submission",
      "color": Colors.red,
    },
    {
      "title": "History Proj",
      "date": "15/03",
      "comment": "Main Hall",
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
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    List<String> weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
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

  void _showMapMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200), // 动画时长
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320, // 固定宽度，显得精致
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Campus", 
                    style: GoogleFonts.inter(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                    )
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Navigate to your destination", 
                    style: GoogleFonts.inter(
                      fontSize: 12, 
                      color: Colors.grey.shade500
                    )
                  ),
                  const SizedBox(height: 24),
                  
                  // 选项 1: Main Campus
                  _buildMinimalMapOption(
                    context, 
                    "Main Campus (Parit Raja)", 
                    Icons.business_rounded, 
                    Colors.redAccent, 
                    kMapLinkMain
                  ),
                  
                  const SizedBox(height: 12), // 上下间距
                  
                  // 选项 2: Pagoh Campus
                  _buildMinimalMapOption(
                    context, 
                    "Pagoh Campus", 
                    Icons.school_rounded, 
                    Colors.blueAccent, 
                    kMapLinkPagoh
                  ),
                ],
              ),
            ),
          ),
        );
      },
      // 添加缩放动画
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack).value,
          child: child,
        );
      },
    );
  }
  Widget _buildBrandIconButton({required String imageUrl, required String url}) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Image.network(
        imageUrl,
        height: 30, // Adjust size to match your design
        width: 30,
        fit: BoxFit.contain,
        // Fallback if image fails to load
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.link, color: Colors.black54),
      ),
    );
  }
  // 简约风格的选项组件
  Widget _buildMinimalMapOption(BuildContext context, String title, IconData icon, Color accentColor, String link) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _launchURL(link);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50, // 极浅的背景色
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200), // 细微的边框
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: accentColor.withValues(alpha:0.15), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title, 
                style: GoogleFonts.inter(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600, 
                  color: Colors.black87
                )
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.black87),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildDailyTimetable() {
    const double gapPadding = 8.0;
    return Container(
      height: 140,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCourseOval(title: "DS", time: "8:00 - 10:00"),
            const SizedBox(width: gapPadding),
            _buildTimeGapArrow("4h"),
            const SizedBox(width: gapPadding),
            _buildCourseOval(title: "HCI", time: "2:00 - 4:00"),
            const SizedBox(width: gapPadding),
            _buildTimeGapArrow("0h"),
            const SizedBox(width: gapPadding),
            _buildCourseOval(title: "OS", time: "4:00 - 6:00"),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseOval({required String title, required String time}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 6),
        Text(time, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text("FSKTM BS1", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTimeGapArrow(String duration) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(duration, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
        const Icon(Icons.arrow_right_alt, size: 30, color: Colors.black54),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 顶部 Header
        SizedBox(
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const VideoBackground(),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    stops: [0.0, 0.35],
                    colors: [kPrimaryBlue, Colors.transparent],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFormattedDate(),
                          style: GoogleFonts.lato(
                            color: const Color(0xE6FFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            shadows: [const Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black26)],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_getGreeting()} Lee Rou",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            shadows: [const Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black45)],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0x4DFFFFFF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 1),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.phone, size: 24, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EmergencyContactsPage()),
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

        // 下方内容区域
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ==========================================
              // 菜单区域
              // ==========================================
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5, offset: Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    // 第一行
                    Row(
                      children: [
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.directions_bus_filled_outlined, 'Bus Tracking',
                            onTap: () async => _launchURL('https://uthm.katsana.com/'),
                          ),
                        ),
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.map_outlined, 'Campus Map',
                            // 调用优化后的 Map Menu
                            onTap: () => _showMapMenu(context),
                          ),
                        ),
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.calendar_month_outlined, 'Timetable',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TimetablePage())),
                          ),
                        ),
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.attach_money, 'Finance',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FinancePage())),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 第二行
                    Row(
                      children: [
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.home_work_outlined, 
                            'Hostel',
                            // 调用 home_page2.dart 的 showHostelMenu
                            onTap: () => showHostelMenu(context), 
                          ),
                        ),
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.directions_car_filled_outlined, 
                            'Vehicle',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VehiclePage())),
                          )
                        ),
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.school_outlined, 
                            'Course',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CoursePage())),
                          )
                        ),
                        Expanded(
                          child: _buildMenuIcon(
                            Icons.access_time, 
                            'Reservation',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReservationPage())),
                          )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const Text("Daily Timetable", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              _buildDailyTimetable(),
              
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 3, child: Text("Due Date Reminder", style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 3, child: Text("Comment", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    ...reminders.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(color: item['color'], shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                            Expanded(flex: 2, child: Text(item['date'])),
                            Expanded(flex: 3, child: Text(item['comment'], maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Facebook
                  _buildBrandIconButton(
                    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_(2019).png/600px-Facebook_Logo_(2019).png',
                    url: 'https://www.facebook.com/uthmjohor/?locale=ms_MY',
                  ),
                  const SizedBox(width: 25),
                  
                  // Instagram
                  _buildBrandIconButton(
                    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Instagram_logo_2016.svg/600px-Instagram_logo_2016.svg.png',
                    url: 'https://www.instagram.com/uthmjohor/',
                  ),
                  const SizedBox(width: 25),
                  
                  // LinkedIn
                  _buildBrandIconButton(
                    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/LinkedIn_logo_initials.png/600px-LinkedIn_logo_initials.png',
                    url: 'https://www.linkedin.com/school/universiti-tun-hussein-onn-malaysia/',
                  ),
                  const SizedBox(width: 25),
                  
                  // Website (Using an icon as it's not a "brand")
                  InkWell(
                    onTap: () => _launchURL('https://www.uthm.edu.my/en/'),
                    child: const Icon(Icons.language, color: Colors.black54, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}

class VideoBackground extends StatefulWidget {
  const VideoBackground({super.key});

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/bluesky.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        setState(() {
          _isInitialized = true;
        });
      }).catchError((error) {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_isInitialized)
          FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          )
        else
          Container(color: kPrimaryBlue),
      ],
    );
  }
}

// ==========================================================
// 3. 紧急联系人页面 & 模拟通话页面
// ==========================================================
class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  final List<Map<String, String>> contacts = const [
    {"name": "MERS 999 (Ambulance/Fire Rescue/Police)", "number": "999"},
    {"name": "UTHM Auxiliary Police & Security Office - APSeM (24 Hours)", "number": "074533435"},
    {"name": "University Medical Centre (Parit Raja)", "number": "0198687854"},
    {"name": "University Medical Centre (Pagoh)", "number": "0199917137"},
    {"name": "UTHM OSHE", "number": "074537228"},
    {"name": "UTHM Development & Maintenance Office", "number": "074533333"},
    {"name": "Batu Pahat Police HQ", "number": "07436330"},
    {"name": "Batu Pahat Police Station", "number": "074341222"},
    {"name": "Parit Raja Police Station", "number": "074541222"},
    {"name": "Sri Gading Police Station", "number": "074558222"},
    {"name": "Ayer Hitam Police Station", "number": "077581222"},
  ];

  void _showConfirmation(BuildContext context, String name, String number) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: Text("Call $name ($number)?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MockCallingPage(name: name, number: number),
                  ),
                );
              },
              child: const Text("Yes", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Emergency Contacts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0025CC), Color(0xFF42A5F5)],
          ),
        ),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white30),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                title: Text(contact['name']!, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                subtitle: Text(contact['number']!, style: GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
                trailing: const Icon(Icons.phone, color: Colors.white),
                onTap: () {
                  _showConfirmation(context, contact['name']!, contact['number']!);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// 模拟通话页面
class MockCallingPage extends StatelessWidget {
  final String name;
  final String number;

  const MockCallingPage({super.key, required this.name, required this.number});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), 
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Calling...",
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
            FloatingActionButton.large(
              onPressed: () => Navigator.pop(context), // 挂断返回
              backgroundColor: Colors.red,
              shape: const CircleBorder(),
              child: const Icon(Icons.call_end, color: Colors.white, size: 40),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 4. 财务页面 (FinancePage)
// ==========================================================
class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

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

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("DETAILS FOR SESSION 202420251", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                    InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, size: 20, color: Colors.grey))
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        color: const Color(0xFF000080),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(flex: 5, child: Text("FEES / SERVICES / FINES", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                            Expanded(flex: 2, child: Text("CODE", textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                            Expanded(flex: 2, child: Text("DEBIT (MYR)", textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                          ],
                        ),
                      ),
                      _buildDetailRow("Tabung Aktiviti Pelajar", "E15109", "20"),
                      _buildDetailRow("Tabung Pusat Kesihatan Universiti", "E15221", "20"),
                      _buildDetailRow("Yuran Pengajian Ijazah", "H79102", "700"),
                      _buildDetailRow("Yuran Perkhidmatan ICT", "H79108", "25"),
                      _buildDetailRow("Yuran Dana Ihsan", "E15103", "10"),
                      _buildDetailRow("Tabung MHS", "E15110", "150"),
                      _buildDetailRow("Dana Wakaf Pendidikan", "E15511", "10"),
                      _buildDetailRow("Yuran Perkhidmatan UTHM", "H79107", "110"),
                      _buildDetailRow("Tabung Ko-Kurikulum", "E15104", "200"),
                      _buildDetailRow("Tabung Khidmat Pelajar", "E15106", "25"),
                      _buildDetailRow("Tabung Pusat Sukan", "E15112", "150"),
                      _buildDetailRow("Tabung Alumni", "E15108", "100"),
                      _buildDetailRow("Yuran Sijil Profesional (FSKTM)", "E80127", "125"),
                      _buildDetailRow("Bayaran Pelekat Elektrik", "H73104", "18"),
                      _buildDetailRow("Yuran Pendaftaran Ijazah", "H79105", "70"),
                      _buildDetailRow("Yuran Asrama Dalam", "H79112", "781"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String name, String code, String debit) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(name, style: GoogleFonts.inter(fontSize: 12))),
          Expanded(flex: 2, child: Text(code, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12))),
          Expanded(flex: 2, child: Text(debit, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Finance", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFF000080), 
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: _buildHeaderText("SEMESTER/SESSION")),
                        Expanded(flex: 2, child: _buildHeaderText("DEBIT\n(MYR)")),
                        Expanded(flex: 2, child: _buildHeaderText("CREDIT\n(MYR)")),
                        Expanded(flex: 2, child: _buildHeaderText("BALANCE\n(MYR)")),
                        Expanded(flex: 2, child: _buildHeaderText("")), 
                      ],
                    ),
                  ),
                  _buildFinanceRow(context, "1 / 20242025", "2514", "2514", "0", "Details"),
                  _buildFinanceRow(context, "2 / 20242025", "1664", "1664", "0", "Details"),
                  _buildFinanceRow(context, "1 / 20252026", "1035", "1035", "0", "Details"),
                  
                  Container(
                    color: Colors.grey.shade200,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text("TOTAL", textAlign: TextAlign.right, style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("5213", textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("5213", textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("0", textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.red))), 
                        const Expanded(flex: 2, child: SizedBox()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text("IMPORTANT REMINDER", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildBulletPoint("Payment can be made by ONLINE PAYMENT : ", linkText: kFinancePaymentLink),
            const SizedBox(height: 8),
            _buildBulletPoint("Failure to do so will result in cancellation of course registration, suspension of examination results and any other actions as imposed in the Student's Payment Rules and Regulations (Pekeliling Bendahari Bil. 10/2008)"),
            const SizedBox(height: 20),
            Text("Thank you for your cooperation.", style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 80), // 留出底部按钮的空间
          ],
        ),
      ),
      // 增加 Make Payment 按钮 (固定在底部)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), offset: const Offset(0, -4), blurRadius: 10)],
        ),
        child: ElevatedButton.icon(
          onPressed: () => _launchURL(kFinancePaymentLink),
          icon: const Icon(Icons.payment, color: Colors.white),
          label: Text("Make Payment Online", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(text, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10));
  }

  Widget _buildFinanceRow(BuildContext context, String session, String debit, String credit, String balance, String action) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200)), color: Colors.white),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(session, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, color: Colors.black))),
          Expanded(flex: 2, child: Text(debit, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11))),
          Expanded(flex: 2, child: Text(credit, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11))),
          Expanded(flex: 2, child: Text(balance, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11))),
          Expanded(
            flex: 2, 
            child: InkWell(
              onTap: () => _showDetailsDialog(context),
              child: Text(action, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, {String? linkText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(color: Colors.black, fontSize: 13, height: 1.4),
              children: [
                TextSpan(text: text),
                if (linkText != null)
                  WidgetSpan(
                    child: InkWell(
                      onTap: () => _launchURL(linkText),
                      child: Text(
                        linkText,
                        style: GoogleFonts.inter(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// 5. 完整的周课表页面 (TimetablePage)
// ==========================================================
class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  // ignore: unused_field
  bool _canPop = false; 

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Course>> weeklySchedule = {
      'Monday': [
        Course(
          code: 'BIC1013',
          name: 'STRUKTUR DISKRIT',
          location: 'I-FSKTM-BS1',
          startHour: 8,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA, 
        ),
        Course(
          code: 'BIM30503',
          name: 'INTERAKSI MANUSIA KOMPUTER',
          location: 'I-PERP-BT9-GS',
          startHour: 14, 
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA, 
        ),
        Course(
          code: 'BIC20803',
          name: 'SISTEM PENGOPERASIAN',
          location: 'I-FSKTM-BS1',
          startHour: 16, 
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA, 
        ),
      ],
      'Tuesday': [
        Course(
          code: 'BIC20904',
          name: 'PENGATURCARAAN BERORIENTASIKAN OBJEK',
          location: 'I-ISYS-ARAS 1',
          startHour: 9, 
          duration: 2,  
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA,
        ),
        Course(
          code: 'BIC1013',
          name: 'STRUKTUR DISKRIT',
          location: 'I-PERP-BT10-GS',
          startHour: 11, 
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkC,
        ),
        Course(
          code: 'UHB 23103',
          name: 'ENGLISH FOR TECHNICAL COMMUNICATION',
          location: 'PERP-BT1',
          startHour: 14,
          duration: 3,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkC,
        ),
      ],
      'Wednesday': [
        Course(
          code: 'BIS20503',
          name: 'KESELAMATAN PERISIAN',
          location: 'I-MKK-ARAS 2',
          startHour: 14,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA, 
        ),
        Course(
          code: 'BIC20803',
          name: 'SISTEM PENGOPERASIAN',
          location: 'I-MSK-ARAS 3',
          startHour: 16,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA, 
        ),
      ],
      'Thursday': [
        Course(
          code: 'BIC20904',
          name: 'PENGATURCARAAN BERORIENTASIKAN OBJEK',
          location: 'I-B8-T1-GS',
          startHour: 8,
          duration: 3,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkB, 
        ),
        Course(
          code: 'BIS20503',
          name: 'KESELAMATAN PERISIAN',
          location: 'I-PERP-BT10-GS',
          startHour: 14,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkC, 
        ),
      ],
      'Friday': [
        Course(
          code: 'BIM30503',
          name: 'INTERAKSI MANUSIA KOMPUTER',
          location: 'I-MGA-ARAS 0',
          startHour: 8,
          duration: 2,
          backgroundColor: Colors.white,
          mapUrl: kMapLinkA, 
        ),
      ],
    };

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Class Timetable",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              setState(() {
                _canPop = true;
              });
              // 修复建议：使用 mounted 检查
              Future.delayed(Duration.zero, () {
                if (context.mounted) Navigator.pop(context);
              });
            },
          ),
        ),
        body: TimetableGrid(schedule: weeklySchedule),
      ),
    );
  }
}

class Course {
  final String code;
  final String name;
  final String location; 
  final int startHour;   
  final int duration;    
  final Color backgroundColor;
  final String mapUrl; 

  Course({
    required this.code,
    required this.name,
    required this.location,
    required this.startHour,
    required this.duration,
    required this.backgroundColor,
    required this.mapUrl,
  });
}

class TimetableGrid extends StatelessWidget {
  final Map<String, List<Course>> schedule;
  
  final int startHour = 8;  
  final int endHour = 18;   
  final double cellHeight = 100.0; 
  final double timeSlotWidth = 110.0; 
  final double dayHeaderWidth = 80.0; 
  
  final List<String> days = const [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'
  ];

  const TimetableGrid({super.key, required this.schedule});

  Future<void> _launchMap(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalGridWidth = timeSlotWidth * (endHour - startHour);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical, 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧固定列 (Header: Day)
          Column(
            children: [
              Container(
                height: 50, 
                width: dayHeaderWidth, 
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kTimetableHeaderColor, // 蓝色
                  border: Border.all(color: kBorderColor, width: 1.5), 
                ),
                child: Text(
                  "Day", 
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
              ...days.map((day) => Container(
                height: cellHeight,
                width: dayHeaderWidth,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kTimetableCellColor, 
                  border: Border.all(color: kBorderColor, width: 1.5), 
                ),
                child: Text(
                  day, 
                  textAlign: TextAlign.center, // Center text
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 11, // CHANGED: Made the font size smaller (original was default ~14)
                  ),
                ),
              )),
            ],
          ),

          // 右侧可滚动区域
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部时间轴
                  Row(
                    children: List.generate(endHour - startHour, (index) {
                      int h = startHour + index;
                      String timeStr = "${h.toString().padLeft(2, '0')}:00 - ${(h+1).toString().padLeft(2, '0')}:00";
                      
                      return Container(
                        width: timeSlotWidth,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kTimetableCellColor, // 浅蓝色
                          border: Border.all(color: kBorderColor, width: 1.5), 
                        ),
                        child: Text(
                          timeStr,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ),

                  // 课程网格
                  SizedBox(
                    height: cellHeight * days.length,
                    width: totalGridWidth,
                    child: Stack(
                      children: [
                        // 背景空网格
                        ...List.generate(days.length, (dayIndex) {
                          return Positioned(
                            top: dayIndex * cellHeight,
                            left: 0,
                            right: 0,
                            height: cellHeight,
                            child: Row(
                              children: List.generate(endHour - startHour, (timeIndex) {
                                return Container(
                                  width: timeSlotWidth,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: kBorderColor, width: 0.5), 
                                  ),
                                );
                              }),
                            ),
                          );
                        }),

                        // 课程卡片
                        ...days.asMap().entries.map((entry) {
                          int dayIndex = entry.key;
                          String dayName = entry.value;
                          List<Course> courses = schedule[dayName] ?? [];

                          return Stack(
                            children: courses.map((course) {
                              double left = (course.startHour - startHour) * timeSlotWidth;
                              double top = dayIndex * cellHeight;
                              double width = course.duration * timeSlotWidth;
                              
                              return Positioned(
                                left: left,
                                top: top,
                                width: width,
                                height: cellHeight,
                                child: Container(
                                  margin: const EdgeInsets.all(0.5),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: course.backgroundColor,
                                    border: Border.all(color: kBorderColor, width: 0.5),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${course.code}\n${course.name}",
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      GestureDetector(
                                        onTap: () {
                                          _launchMap(course.mapUrl);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.black54),
                                            borderRadius: BorderRadius.circular(4),
                                            color: Colors.transparent, 
                                          ),
                                          child: Text(
                                            "[${course.location}]",
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ].expand((i) => i is Stack ? [i] : [i]).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
