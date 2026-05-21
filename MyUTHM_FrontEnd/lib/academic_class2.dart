import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 颜色常量
const Color kHeaderColor = Color(0xFF001C55);
const Color kBorderColor = Color(0xFFEEEEEE);
const Color kLinkColor = Color(0xFFA93226); // 红色链接
const Color kPrimaryBlue = Color(0xFF0422A7);
const Color kStatusFull = Color(0xFFE53935); // 红色 (FULL)
const Color kStatusAvailable = Color(0xFF43A047); // 绿色 (Available)
const Color kNameBlue = Color(0xFF1976D2); // 名字蓝

// =======================================================
//           VIEW 5: GROUP ACTIVITIES (Main Tab)
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

  // 组数据状态 - 更改：hasFiles 变为 files 列表
  final List<Map<String, dynamic>> _groups = [
    {
      "name": "GROUP 1",
      "members": [
        {"name": "AHMAD ALBAB", "id": "AI240001"},
        {"name": "SITI NURHALIZA", "id": "AI240002"},
      ],
      "files": [],
    },
    {
      "name": "GROUP 2",
      "members": [
        {"name": "CHONG WEI HONG", "id": "DI240011"},
      ],
      "files": [],
    },
    {
      "name": "GROUP 3",
      "members": [], // Empty group
      "files": [],
    },
    {
      "name": "GROUP 4",
      "members": [
        {"name": "MUTHU KUMAR", "id": "AI240055"},
        {"name": "JESSICA LEE", "id": "DI240088"},
        {"name": "FARID KAMIL", "id": "AI240099"},
      ],
      "files": [],
    },
    {
      "name": "GROUP 5",
      "members": [
        {"name": "MUHAMMAD AMIRUL BIN ROSLI", "id": "AI240201"},
        {"name": "LEE WEI KANG", "id": "DI240112"},
        {"name": "SIVANESAN A/L MURUGAN", "id": "AI240334"},
        {"name": "NURUL IZZAH BINTI AZMAN", "id": "DI240055"},
      ],
      // 模拟文件数据 (Group 5 才有文件)
      "files": [
        {
          "name": "[AI240201],project_proposal.pdf",
          "size": "166.1KB",
          "uploaderId": "AI240201", // 模拟上传者ID
          "date": "29 Oct 2025 @ 11:59 PM [1 Months ago]",
        }
      ],
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

  // --- 新增: 删除文件函数 ---
  void _deleteFile(String groupName, int fileIndex) {
    setState(() {
      final group = _groups.firstWhere((g) => g['name'] == groupName);
      if (group['files'].length > fileIndex) {
        // 实际应用中，这里应该调用 API 删除文件
        group['files'].removeAt(fileIndex);
        // 可以添加一个 snackbar 提示用户文件已删除
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File deleted from $groupName.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
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
                files: List<Map<String, String>>.from(group['files']), // 传递文件列表
                isFull: isFull,
                isMember: isMember, 
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
    required List<Map<String, String>> files, // 接收文件列表
    required bool isFull,
    required bool isMember,
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
          if (files.isNotEmpty) ...[ // 判断文件列表是否为空
            const Divider(height: 1, color: kBorderColor),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Files Submitted",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kNameBlue, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  // 遍历文件列表
                  ...files.asMap().entries.map((entry) {
                    final int fileIndex = entry.key;
                    final Map<String, String> file = entry.value;
                    final bool canDelete = file['uploaderId'] == _currentUser['id'] || members.first['id'] == _currentUser['id']; // 只有上传者或组长可以删除 (这里简化逻辑，假设第一个成员是组长)

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 文件信息
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${fileIndex + 1}. ", style: const TextStyle(fontSize: 13)),
                                const Icon(Icons.picture_as_pdf, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file["name"]!,
                                        style: GoogleFonts.poppins(fontSize: 13, color: kLinkColor, decoration: TextDecoration.underline),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${file["size"]}, ${file["date"]}",
                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 删除按钮 (只在文件上传者或组长是当前用户时显示)
                          if (canDelete)
                            InkWell(
                              onTap: () => _deleteFile(groupName, fileIndex),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.delete_outline, color: kStatusFull, size: 24),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
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
//           VIEW: ASSESSMENT TAB
// (保持不变)
// =======================================================
class AssessmentTab extends StatefulWidget {
  const AssessmentTab({super.key});

  @override
  State<AssessmentTab> createState() => _AssessmentTabState();
}

class _AssessmentTabState extends State<AssessmentTab> {
  // 模拟 Quiz 数据
  final List<Map<String, String>> _quizList = [];

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
//           VIEW: MARKS TAB
// (保持不变)
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
//           VIEW: LECTURER PROFILE TAB
// (保持不变)
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