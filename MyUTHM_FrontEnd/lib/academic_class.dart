import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 【重要】引入 main.dart 以便使用 mainGlobalKey 控制主页 Tab 切换
import 'main.dart'; 

// 颜色常量
const Color kHeaderColor = Color(0xFF001C55); 
const Color kBorderColor = Color(0xFFEEEEEE);
const Color kLinkColor = Color(0xFFA93226); // 红色链接
const Color kPrimaryBlue = Color(0xFF0422A7);
const Color kStatusFull = Color(0xFFE53935); // 红色 (FULL)
const Color kStatusAvailable = Color(0xFF43A047); // 绿色 (Available)
const Color kNameBlue = Color(0xFF1976D2); // 名字蓝
const Color kBackgroundColor = Color(0xFFF4F6FC); // 背景色

// 其他颜色常量 (用于 Tab 和 详情页)
const Color kTabShadowColor = Color(0x0D9E9E9E);
const Color kCoordOrange   = Color(0xFFEF6C00); 
const Color kCoordBlue     = Color(0xFF1565C0); 
const Color kCoordGreen    = Color(0xFF2E7D32); 
const Color kCoordYellow   = Color(0xFFFFCA28); 
const Color kCoordInfo     = Color(0xFF455A64); 
const Color kTrashRed      = Color(0xFFC62828);
const Color kSelectionBg   = Color(0xFFE3F2FD);
const Color kLightBlueBg   = Color(0x1A0422A7); 

// =======================================================
//           ACADEMIC CLASS PAGE (Host Scaffold)
// =======================================================
class AcademicClassPage extends StatefulWidget {
  final Map<String, String> courseData;

  const AcademicClassPage({super.key, required this.courseData});

  @override
  State<AcademicClassPage> createState() => _AcademicClassPageState();
}

class _AcademicClassPageState extends State<AcademicClassPage> {
  String _currentDetailTab = "Stream";
  String? _openedFolderName;
  Map<String, String>? _openedActivityData;
  final Set<int> _selectedIndices = {};
  
  // 底部导航栏的当前索引 (Academic 是 1)
  final int _bottomNavIndex = 1; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "${widget.courseData['code']} : ${widget.courseData['name']}",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      
      // --- FAB (Scan) 修复跳转 ---
      floatingActionButton: SizedBox(
        width: 75,
        height: 75,
        child: FloatingActionButton(
          onPressed: () {
             // 1. 切换主页 Tab 到 Scan (Index 2)
             mainGlobalKey.currentState?.switchToTab(2);
             // 2. 关闭当前详情页，返回主页
             Navigator.of(context).popUntil((route) => route.isFirst);
          },
          backgroundColor: kPrimaryBlue,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 70,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.menu_book, 'Academic', 1),
            const SizedBox(width: 40), // 中间留白
            _buildNavItem(Icons.notifications_outlined, 'Notification', 3),
            _buildNavItem(Icons.person_outline, 'Profile', 4),
          ],
        ),
      ),

      body: Column(
        children: [
          // 1. 顶部 Tab 菜单栏
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: kBorderColor)),
            ),
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.start,
              children: [
                _buildTabButton("Stream", icon: Icons.chat_bubble_outline, isActive: _currentDetailTab == "Stream"),
                _buildTabButton("Learning Materials", icon: Icons.computer, isActive: _currentDetailTab == "Learning Materials"),
                _buildTabButton("Past Year Questions", icon: Icons.history, isActive: _currentDetailTab == "Past Year Questions"),
                _buildTabButton("Individual Activities", icon: Icons.person_outline, isActive: _currentDetailTab == "Individual Activities"),
                _buildTabButton("Group Activities", icon: Icons.people_outline, isActive: _currentDetailTab == "Group Activities"),
                _buildTabButton("Assessment", icon: Icons.quiz_outlined, isActive: _currentDetailTab == "Assessment"),
                _buildTabButton("Marks", icon: Icons.bar_chart, isActive: _currentDetailTab == "Marks"),
                _buildTabButton("Lecturer Profile", icon: Icons.badge_outlined, isActive: _currentDetailTab == "Lecturer Profile"),
              ],
            ),
          ),

          // 2. 视觉隔断
          if (["Learning Materials", "Past Year Questions", "Individual Activities"].contains(_currentDetailTab))
            Container(
              height: 16, 
              width: double.infinity,
              color: kBackgroundColor, 
            ),

          // 3. 内容区域
          Expanded(
            child: Container(
              color: kBackgroundColor,
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  // --- 关键修改：导航跳转逻辑 ---
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _bottomNavIndex == index;
    Color color = isSelected ? kPrimaryBlue : Colors.grey;

    return InkWell(
      onTap: () {
        if (index == 0) {
           // Home: 切换 Tab 并退出当前页
           mainGlobalKey.currentState?.switchToTab(0);
           Navigator.of(context).popUntil((route) => route.isFirst);
        } 
        else if (index == 1) {
           // Academic: 当前就是 Academic 体系，这里可以选择只是 pop 回列表，或者不做操作
           // 如果想回列表：Navigator.pop(context);
        }
        else if (index == 3) {
           // Notification: 切换 Tab 并退出当前页
           mainGlobalKey.currentState?.switchToTab(3);
           Navigator.of(context).popUntil((route) => route.isFirst);
        }
        else if (index == 4) {
           // Profile: 切换 Tab 并退出当前页
           mainGlobalKey.currentState?.switchToTab(4);
           Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
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

  Widget _buildTabContent() {
    switch (_currentDetailTab) {
      case "Stream":
        return _buildStreamContent(widget.courseData['lecturer'] ?? "Lecturer");
      
      case "Learning Materials":
        if (_openedFolderName == null) {
          return _buildMaterialsFolderList(); 
        } else {
          return _buildMaterialsFileList();   
        }
      
      case "Past Year Questions":
        return _buildPastYearQuestionsContent();
      
      case "Individual Activities":
        if (_openedActivityData == null) {
          return _buildIndividualActivitiesList(); 
        } else {
          return _buildIndividualActivityDetail(); 
        }

      case "Group Activities":
        return const GroupActivitiesTab(); 
      
      case "Assessment":
        return const AssessmentTab();

      case "Marks":
        return const MarksTab(); 

      case "Lecturer Profile":
        return const LecturerProfileTab(); 

      default:
        return const SizedBox.shrink();
    }
  }

  void _handleSelectAll(int itemCount) {
    setState(() {
      _selectedIndices.clear();
      for (int i = 0; i < itemCount; i++) {
        _selectedIndices.add(i);
      }
    });
  }

  void _handleClearSelection() {
    setState(() {
      _selectedIndices.clear();
    });
  }

  // =======================================================
  //       VIEW: PAST YEAR QUESTIONS
  // =======================================================
  Widget _buildPastYearQuestionsContent() {
    final List<Map<String, String>> pastYears = [
      {"title": "DISCRETE STRUCTURE - BIC 10103", "year": "2025"},
      {"title": "DISCRETE STRUCTURE - BIC 10103", "year": "2025"},
      {"title": "DISCRETE STRUCTURE - BIC 10103", "year": "2024"},
      {"title": "DISCRETE STRUCTURE - BIC 10103", "year": "2023"},
      {"title": "DISCRETE STRUCTURE - BIC 10103", "year": "Jan-2022"},
      {"title": "Discrete Structure - BIC10103", "year": "2021"},
    ];

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              const Icon(Icons.history_edu, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                "Past Year Questions List",
                style: GoogleFonts.poppins(color: Colors.grey.shade700, fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: kBorderColor),
        _buildActionBar(itemCount: pastYears.length),
        Expanded(
          child: ListView.separated(
            itemCount: pastYears.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: kBorderColor),
            itemBuilder: (context, index) {
              final item = pastYears[index];
              final isSelected = _selectedIndices.contains(index);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedIndices.remove(index);
                    } else {
                      _selectedIndices.add(index);
                    }
                  });
                },
                child: Container(
                  color: isSelected ? kSelectionBg : Colors.white, 
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Icon(
                          isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                          color: isSelected ? kPrimaryBlue : Colors.grey.shade400,
                          size: 20
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: Wrap( 
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8.0, 
                          children: [
                            Text(
                              item["title"]!.toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF1565C0), 
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFF1565C0),
                              ),
                            ),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300)
                              ),
                              child: Text(
                                item["year"]!,
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // =======================================================
  //       VIEW: INDIVIDUAL ACTIVITY DETAIL
  // =======================================================
  Widget _buildIndividualActivityDetail() {
    final activity = _openedActivityData!;
    final dueDateStr = activity['dueDate']!;
    
    bool isExpired = false;
    String remainingText = "";
    
    if (dueDateStr == "---") {
      isExpired = false;
      remainingText = "NO DUE DATE";
    } else {
      if (dueDateStr.contains("Oct") || dueDateStr.contains("Nov")) {
        isExpired = true;
      } else {
        isExpired = false;
        remainingText = "REMAINING: 26 DAYS 2 HOURS";
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumb(
            items: ["Activity List", "Folder"],
            onTapRoot: () {
              setState(() {
                _openedActivityData = null; 
                _selectedIndices.clear();
              });
            },
          ),
          const Divider(height: 1, color: kBorderColor),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: kCoordOrange, 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text("Due Date:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dueDateStr == "---" ? "No Due Date" : dueDateStr,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: isExpired ? kCoordBlue : kCoordGreen, 
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isExpired 
                              ? "EXPIRED: SUBMISSION WILL BE LATE"
                              : remainingText,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ).height(100),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: kCoordBlue, 
                  child: const Text(
                    "Files",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        activity['file'] ?? "No attached files.",
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      if (activity['file'] != null)
                        Text(", (153.3KB)", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: kCoordInfo,
                  child: const Text(
                    "Upload your assignment files here (Max. 100MByte Per-file). Double confirm files aren't corrupted.",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),

                Container(
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 140, 
                        color: kCoordYellow,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload, size: 40, color: Colors.black87),
                            const SizedBox(height: 8),
                            Text(
                              "Browse\nfile",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              color: kHeaderColor,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              child: const Row(
                                children: [
                                  Text("#", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 20),
                                  Expanded(child: Text("Your Files", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                  Text("Option", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("1.", style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "ai210160_leerou_s1_lab2.pdf",
                                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Text("2412KB ,25 Oct", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                            Text(
                                              " [1 Months ago]", 
                                              style: TextStyle(fontSize: 11, color: isExpired ? kCoordGreen : Colors.grey, fontWeight: FontWeight.bold)
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      _buildSmallIconButton(Icons.open_in_new, kCoordBlue),
                                      const SizedBox(height: 4),
                                      _buildSmallIconButton(Icons.delete, kTrashRed),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================
  //       VIEW: INDIVIDUAL ACTIVITIES LIST
  // =======================================================
  Widget _buildIndividualActivitiesList() {
    final List<Map<String, String>> activities = [
      {
        "no": "1.",
        "activity": "Tutorial 1",
        "section": "ALL",
        "dueDate": "---",
        "created": "13 Oct 2025\n@ 10:40 AM"
      },
      {
        "no": "2.",
        "activity": "Tutorial 2(a)",
        "section": "ALL",
        "dueDate": "27 Oct 2025 @ 6:00 AM", 
        "created": "21 Oct 2025\n@ 10:41 AM",
        "file": "tutorial02-28a-29.pdf"
      },
      {
        "no": "3.",
        "activity": "Tutorial 2(b)",
        "section": "ALL",
        "dueDate": "---",
        "created": "2 Nov 2025\n@ 9:05 PM"
      },
      {
        "no": "4.",
        "activity": "Assignment 1: Mathematical Induction",
        "section": "ALL",
        "dueDate": "30 Dec 2025 @ 11:59 PM", 
        "created": "4 Nov 2025\n@ 3:32 PM",
        "file": "assignment1_math.pdf"
      },
    ];

    return Column(
      children: [
        _buildBreadcrumb(items: ["Activity List", "Folder"]),
        const Divider(height: 1, color: kBorderColor),
        
        Container(
          color: kHeaderColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: const Row(
            children: [
              SizedBox(width: 40, child: Text("No.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text("Activities (Click)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text("Section", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Due Date", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Created", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            itemCount: activities.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, color: kBorderColor),
            itemBuilder: (context, index) {
              final item = activities[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _openedActivityData = item;
                  });
                },
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 40, child: Text(item["no"]!, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87))),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item["activity"]!,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: kLinkColor),
                        ),
                      ),
                      Expanded(flex: 1, child: Text(item["section"]!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87))),
                      Expanded(flex: 2, child: Text(item["dueDate"]!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87))),
                      Expanded(flex: 2, child: Text(item["created"]!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Reuse Components ---
  Widget _buildMaterialsFolderList() {
    final List<Map<String, String>> folders = [
      {"no": "4", "title": "Chapter 3: Relations and Functions [2]", "size": "3.2MB", "date": "20 Nov 2025"},
      {"no": "2", "title": "Chapter 2: Mathematical Induction [1]", "size": "1.5MB", "date": "05 Nov 2025"},
      {"no": "1", "title": "Chapter 1: BASIC OF LOGIC AND PROOF [2]", "size": "2.8MB", "date": "13 Oct 2025"},
      {"no": "3", "title": "Chapter 0: Introduction [1]", "size": "500KB", "date": "01 Oct 2025"},
    ];
    return _buildGenericList(folders, isFolder: true);
  }

  Widget _buildMaterialsFileList() {
    final List<Map<String, String>> files = [
      {"no": "2", "name": "chapter1b_predicateaquantifier.pptx", "size": "1312.4KB", "date": "2 Nov 2025 @ 9:15 PM"},
      {"no": "1", "name": "chapter1a_logicaproof.pptx", "size": "1579.2KB", "date": "13 Oct 2025 @ 9:52 AM"},
    ];
    return Column(
      children: [
        _buildBreadcrumb(
          items: ["Material List", _openedFolderName ?? ""],
          onTapRoot: () {
            setState(() {
              _openedFolderName = null; 
              _selectedIndices.clear();
            });
          },
        ),
        const Divider(height: 1, color: kBorderColor),
        _buildActionBar(itemCount: files.length),
        _buildTableHeader(showSizeDate: true),
        Expanded(
          child: ListView.separated(
            itemCount: files.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, color: kBorderColor),
            itemBuilder: (context, index) {
              final file = files[index];
              final isSelected = _selectedIndices.contains(index);
              return InkWell(
                onTap: () {
                   setState(() {
                    if (isSelected) {
                      _selectedIndices.remove(index);
                    } else {
                      _selectedIndices.add(index);
                    }
                  });
                },
                child: Container(
                  color: isSelected ? kSelectionBg : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    children: [
                      _buildCheckbox(isSelected),
                      SizedBox(width: 50, child: Center(child: Text(file["no"]!, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)))),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.description, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(file["name"]!, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      SizedBox(width: 80, child: Text(file["size"]!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700))),
                      const SizedBox(width: 10),
                      SizedBox(width: 130, child: Text(file["date"]!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenericList(List<Map<String, String>> items, {bool isFolder = false}) {
     return Column(
      children: [
        _buildListHeaderTitle("Material List"),
        const Divider(height: 1, color: kBorderColor),
        _buildActionBar(itemCount: items.length),
        _buildTableHeader(showSizeDate: true),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, color: kBorderColor),
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = _selectedIndices.contains(index);
              return InkWell(
                onTap: () {
                   if (isFolder && item["title"]!.startsWith("Chapter 1")) {
                    setState(() {
                      _openedFolderName = "Chapter 1: BASIC OF LOGIC AND PROOF";
                      _selectedIndices.clear(); 
                    });
                  }
                },
                child: Container(
                  color: isSelected ? kSelectionBg : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () { 
                          setState(() { 
                            if (isSelected) {
                              _selectedIndices.remove(index);
                            } else {
                              _selectedIndices.add(index); 
                            }
                          }); 
                        },
                        child: _buildCheckbox(isSelected),
                      ),
                      SizedBox(width: 50, child: Center(child: Text(item["no"]!, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)))),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(isFolder ? Icons.folder : Icons.description, color: isFolder ? const Color(0xFFFFC107) : Colors.grey, size: 24),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item["title"]!, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      SizedBox(width: 80, child: Text(item["size"]!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700))),
                      const SizedBox(width: 10),
                      SizedBox(width: 130, child: Text(item["date"]!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Common Widgets ---
  Widget _buildCheckbox(bool isSelected) {
    return SizedBox(
      width: 30, 
      child: Icon(
        isSelected ? Icons.check_box : Icons.check_box_outline_blank, 
        color: isSelected ? kPrimaryBlue : Colors.grey.shade400, 
        size: 20
      ),
    );
  }
  
  Widget _buildSmallIconButton(IconData icon, Color color) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildBreadcrumb({required List<String> items, VoidCallback? onTapRoot}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          ...items.asMap().entries.map((entry) {
            int idx = entry.key;
            String text = entry.value;
            bool isFirst = idx == 0; 

            return Row(
              children: [
                isFirst && onTapRoot != null
                    ? InkWell(
                        onTap: onTapRoot,
                        child: Text(
                          text,
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade700, 
                            fontWeight: FontWeight.w600, 
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : Text(
                        text,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                if (idx < items.length - 1) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                  const SizedBox(width: 8),
                ]
              ],
            );
          }).toList(),
          const SizedBox(width: 8),
          const Icon(Icons.folder_open, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildListHeaderTitle(String title) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Icon(Icons.folder_copy_outlined, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.poppins(color: Colors.grey.shade700, fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActionBar({required int itemCount}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildActionButton(Icons.check_box_outline_blank, "Select All", () => _handleSelectAll(itemCount)),
            const SizedBox(width: 20),
            _buildActionButton(Icons.close, "Clear Selection", _handleClearSelection),
            const SizedBox(width: 20),
            _buildActionButton(Icons.download, "Download Selected", () { /* Logic */ }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader({bool showSizeDate = false}) {
    return Container(
      color: kHeaderColor, 
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          const SizedBox(width: 30, child: Text("#", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const SizedBox(width: 50, child: Center(child: Text("No.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(child: Text("File Name", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))),
          if (showSizeDate) ...[const SizedBox(width: 48), const SizedBox(width: 80, child: Text("Size", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), const SizedBox(width: 10), const SizedBox(width: 130, child: Text("Date Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),]
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStreamContent(String lecturerName) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStreamPost(lecturerName: lecturerName, date: "04-12-2025 09:00:00 AM [Just Now]", content: 'IMPORTANT: The Mid-term Test will be held on 15th Dec 2025.', isNew: true),
        const SizedBox(height: 16),
        _buildStreamPost(lecturerName: lecturerName, date: "02-12-2025 12:11:08 PM [2 Days ago]", content: 'Learning Material in TOPIC "Chapter 3: Relations and Functions" uploaded.', isNew: true),
      ],
    );
  }

  Widget _buildStreamPost({required String lecturerName, required String date, required String content, bool isNew = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200)), borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Color(0xFFE91E63), child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                        Text(lecturerName, style: GoogleFonts.poppins(color: const Color(0xFF2196F3), fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(width: 4), Text("created a new post", style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14)),
                        if (isNew) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2)), child: const Text("NEW", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)))]
                    ]),
                    const SizedBox(height: 2), Text(date, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), Padding(padding: const EdgeInsets.only(left: 52.0), child: Text(content, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, {IconData? icon, bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentDetailTab = label;
          _openedFolderName = null;
          _openedActivityData = null;
          _selectedIndices.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? kPrimaryBlue : Colors.grey.shade300),
          boxShadow: isActive ? [] : [const BoxShadow(color: kTabShadowColor, offset: Offset(0, 1), blurRadius: 2)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [if (icon != null) ...[Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey.shade600), const SizedBox(width: 8)], Text(label, style: GoogleFonts.poppins(fontSize: 13, color: isActive ? Colors.white : Colors.grey.shade600, fontWeight: isActive ? FontWeight.w500 : FontWeight.w400))]),
      ),
    );
  }
}

extension WidgetExt on Widget {
  Widget height(double h) => SizedBox(height: h, child: this);
}

// =======================================================
//           VIEW 5: GROUP ACTIVITIES (Main Tab)
// =======================================================
class GroupActivitiesTab extends StatefulWidget {
  const GroupActivitiesTab({super.key});

  @override
  State<GroupActivitiesTab> createState() => _GroupActivitiesTabState();
}

class _GroupActivitiesTabState extends State<GroupActivitiesTab> {
  // 追踪当前选中的活动 (null 表示在列表页, 有值表示在组选择页)
  String? _selectedActivity;

  // 模拟当前登录的用户
  final Map<String, String> _currentUser = {
    "name": "MY NAME (ME)", // 这里显示你的名字
    "id": "AI248888"
  };

  // 组数据状态
  final List<Map<String, dynamic>> _groups = [
    {
      "name": "GROUP 1",
      "members": [
         {"name": "AHMAD ALBAB", "id": "AI240001"},
         {"name": "SITI NURHALIZA", "id": "AI240002"},
      ],
      "hasFiles": false,
    },
    {
      "name": "GROUP 2",
      "members": [
         {"name": "CHONG WEI HONG", "id": "DI240011"},
      ],
      "hasFiles": false,
    },
    {
      "name": "GROUP 3",
      "members": [], // Empty group
      "hasFiles": false,
    },
    {
      "name": "GROUP 4",
      "members": [
         {"name": "MUTHU KUMAR", "id": "AI240055"},
         {"name": "JESSICA LEE", "id": "DI240088"},
         {"name": "FARID KAMIL", "id": "AI240099"},
      ],
      "hasFiles": false,
    },
    {
      "name": "GROUP 5",
      "members": [
         {"name": "MUHAMMAD AMIRUL BIN ROSLI", "id": "AI240201"},
         {"name": "LEE WEI KANG", "id": "DI240112"},
         {"name": "SIVANESAN A/L MURUGAN", "id": "AI240334"},
         {"name": "NURUL IZZAH BINTI AZMAN", "id": "DI240055"},
      ],
      "hasFiles": true,
    }
  ];

  @override
  Widget build(BuildContext context) {
    if (_selectedActivity == null) {
      return _buildActivityList();
    } else {
      return _buildGroupSelectionList();
    }
  }

  // --- 1. 活动列表视图 (Activity List) ---
  Widget _buildActivityList() {
    final List<Map<String, String>> groupActivities = [
      {
        "no": "1.",
        "activity": "Group Project : 1-Page Proposal",
        "dueDate": "Saturday, 1 Nov 2025 @ 11:59 PM",
        "section": "ALL",
        "created": "15 Oct 2025"
      },
    ];

    return Column(
      children: [
        _buildBreadcrumb(items: ["Activity List", "Folder"]),
        const Divider(height: 1, color: kBorderColor),

        Container(
          color: kHeaderColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: const Row(
            children: [
              SizedBox(width: 40, child: Text("No.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text("Activities (Click)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Due Date", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text("Section", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Expanded(flex: 1, child: Text("Created", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            itemCount: groupActivities.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, color: kBorderColor),
            itemBuilder: (context, index) {
              final item = groupActivities[index];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedActivity = item["activity"];
                  });
                },
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 40, child: Text(item["no"]!, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87))),
                      Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.people, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item["activity"]!,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: kLinkColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(flex: 2, child: Text(item["dueDate"]!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87))),
                      Expanded(flex: 1, child: Text(item["section"]!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87))),
                      Expanded(flex: 1, child: Text(item["created"]!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 2. 组选择视图 (Group Selection List) ---
  Widget _buildGroupSelectionList() {
    return Column(
      children: [
        _buildBreadcrumb(
          items: ["Activity List", "Groups"],
          onTapRoot: () {
            setState(() {
              _selectedActivity = null; 
            });
          },
        ),
        const Divider(height: 1, color: kBorderColor),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: const Color(0xFFE3F2FD), 
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: kPrimaryBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Please select a group to join. Maximum 5 members per group.",
                  style: GoogleFonts.poppins(color: kPrimaryBlue, fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _groups.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final group = _groups[index];
              final List members = group['members'];
              
              // 逻辑：判断当前用户是否在这个组里
              final bool isMember = members.any((m) => m['id'] == _currentUser['id']);
              final bool isFull = members.length >= 5;

              return _buildGroupCard(
                groupName: group['name'],
                members: List<Map<String, String>>.from(members),
                isFull: isFull,
                isMember: isMember, 
                hasFiles: group['hasFiles'],
                onJoin: () {
                  setState(() {
                    if (members.length < 5) {
                      group['members'].add(_currentUser);
                    }
                  });
                },
                onQuit: () {
                  setState(() {
                    group['members'].removeWhere((m) => m['id'] == _currentUser['id']);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 辅助组件: 组卡片 ---
  Widget _buildGroupCard({
    required String groupName,
    required List<Map<String, String>> members,
    required bool isFull,
    required bool isMember,
    bool hasFiles = false,
    required VoidCallback onJoin,
    required VoidCallback onQuit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 1. 卡片头部
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.groups, size: 40, color: Colors.orange), 
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 动态显示按钮
                      if (isMember)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green)
                          ),
                          child: const Text("JOINED", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                        )
                      else if (isFull)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                          decoration: BoxDecoration(
                            color: kStatusFull,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "FULL",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: onJoin,
                          icon: const Icon(Icons.add, size: 16, color: Colors.white),
                          label: const Text("JOIN THIS GROUP", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kStatusAvailable,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      Text(
                        groupName,
                        style: GoogleFonts.poppins(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: kNameBlue
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${members.length} of 5 (MAX) joined. ${5 - members.length} available",
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                ),

                // --- 只有在是成员时显示三个点菜单 ---
                if (isMember) 
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (String result) {
                      if (result == 'quit') {
                        onQuit(); 
                      }
                      // upload logic would go here
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'upload',
                        child: Row(
                          children: [
                            Icon(Icons.upload_file, size: 20, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Upload File'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'quit',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Quit Group', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: kBorderColor),

          // 2. 成员列表
          if (members.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: members.map((member) {
                  final bool isMe = member['id'] == "AI248888"; 

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: isMe ? kPrimaryBlue : Colors.grey, 
                          child: const Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member["name"]!,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isMe ? kPrimaryBlue : kNameBlue,
                              ),
                            ),
                            Text(
                              member["id"]!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // 3. 文件提交区
          if (hasFiles) ...[
            const Divider(height: 1, color: kBorderColor),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.folder_shared, size: 36, color: Color(0xFFFFC107)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Files Submitted",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kNameBlue, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("1. ", style: TextStyle(fontSize: 13)),
                            const Icon(Icons.picture_as_pdf, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "[AI240201],project_proposal.pdf",
                                style: GoogleFonts.poppins(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "166.1KB, 29 Oct 2025 @ 11:59 PM [1 Months ago]",
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: kStatusAvailable,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.calendar_today, size: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreadcrumb({required List<String> items, VoidCallback? onTapRoot}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          ...items.asMap().entries.map((entry) {
            int idx = entry.key;
            String text = entry.value;
            bool isFirst = idx == 0;

            return Row(
              children: [
                isFirst && onTapRoot != null
                    ? InkWell(
                        onTap: onTapRoot,
                        child: Text(
                          text,
                          style: GoogleFonts.poppins(color: Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.underline),
                        ),
                      )
                    : Text(text, style: GoogleFonts.poppins(color: Colors.grey.shade700, fontWeight: FontWeight.w500, fontSize: 14)),
                if (idx < items.length - 1) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                  const SizedBox(width: 8),
                ]
              ],
            );
          }).toList(),
          const SizedBox(width: 8),
          const Icon(Icons.folder_open, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}

// =======================================================
//           VIEW: ASSESSMENT TAB
// =======================================================
class AssessmentTab extends StatefulWidget {
  const AssessmentTab({super.key});

  @override
  State<AssessmentTab> createState() => _AssessmentTabState();
}

class _AssessmentTabState extends State<AssessmentTab> {
  // 模拟 Quiz 数据
  final List<Map<String, String>> _quizList = [
    // {
    //   "title": "Quiz 1",
    //   "date": "20 Dec 2025",
    //   "time": "10:00 AM"
    // },
  ];

  @override
  Widget build(BuildContext context) {
    if (_quizList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "No record",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _quizList.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final quiz = _quizList[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: kBorderColor),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.quiz, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz["title"]!,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: kHeaderColor),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          "${quiz["date"]} • ${quiz["time"]}",
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =======================================================
//           VIEW: MARKS TAB
// =======================================================
class MarksTab extends StatelessWidget {
  const MarksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> marksData = [
      {
        "no": "1.",
        "assessment": "Poster Affective (5%)",
        "marks": "4.00-(4/5)",
        "date": "24 Jan 2025 - 12:12 PM"
      },
      {
        "no": "2.",
        "assessment": "Poster Psychomotor (10%)",
        "marks": "7.00-(7/10)",
        "date": "24 Jan 2025 - 12:13 PM"
      },
      {
        "no": "3.",
        "assessment": "Project Presentation (5%)",
        "marks": "5.00-(5/5)",
        "date": "24 Jan 2025 - 03:08 PM"
      },
      {
        "no": "4.",
        "assessment": "Project Advertisement (10%)",
        "marks": "8.00-(8/10)",
        "date": "24 Jan 2025 - 12:38 PM"
      },
      {
        "no": "5.",
        "assessment": "Project Report (5%)",
        "marks": "4.50-(4.5/5)",
        "date": "24 Jan 2025 - 12:38 PM"
      },
    ];

    return Column(
      children: [
        // 1. 顶部统计卡片
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.star_border,
                  label: "Marks: -",
                  iconColor: const Color(0xFF26A69A),
                  bgColor: const Color(0xFFE0F2F1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.sentiment_satisfied_alt,
                  label: "Gred: -",
                  iconColor: const Color(0xFF26A69A),
                  bgColor: const Color(0xFFE0F2F1),
                ),
              ),
            ],
          ),
        ),
        
        // 2. 表格头部
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFFF5F7FA),
          child: Row(
            children: [
              SizedBox(width: 30, child: Text("No.", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
              Expanded(flex: 4, child: Text("Assessment", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
              Expanded(flex: 3, child: Text("Marks", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
              Expanded(flex: 3, child: Text("Date", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
            ],
          ),
        ),

        // 3. 表格内容
        Expanded(
          child: ListView.builder(
            itemCount: marksData.length,
            itemBuilder: (context, index) {
              final item = marksData[index];
              final bool isEven = index % 2 == 0;
              final Color rowColor = isEven ? Colors.white : const Color(0xFFF4F8FB); 

              return Container(
                color: rowColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 30, child: Text(item["no"]!, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(item["assessment"]!, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
                      ),
                    ),
                    Expanded(flex: 3, child: Text(item["marks"]!, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87))),
                    Expanded(flex: 3, child: Text(item["date"]!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({required IconData icon, required String label, required Color iconColor, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: iconColor),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

// =======================================================
//           VIEW: LECTURER PROFILE TAB
// =======================================================
class LecturerProfileTab extends StatelessWidget {
  const LecturerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. 头部图片与头像
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1519681393784-d120267933ba?q=80&w=2070&auto=format&fit=crop'), 
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
                      backgroundImage: NetworkImage('https://img.freepik.com/free-photo/portrait-young-asian-woman-hijab-smiling-camera_23-2149090623.jpg'), 
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. 文本详细信息
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Text(
                  "Dr. Sofia Najwa Binti Ramli",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Email1: sofianajwa@uthm.edu.my",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildDetailItem("Email2", ""),
                _buildDetailItem("Phone", "074533782"),
                _buildDetailItem("Website", ""),
                _buildDetailItem("Facebook", ""),
                _buildDetailItem("Instagram", ""),
                _buildDetailItem("Room", "PB401-14"),
                _buildDetailItem("Faculty", "FSKTM"),
                _buildDetailItem("Classroom Info", ""),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        value.isEmpty ? "$label:" : "$label: $value",
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