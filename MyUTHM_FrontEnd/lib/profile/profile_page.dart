import 'package:flutter/material.dart';
import 'package:uthm/theme/app_colors.dart';
import '../logout_page.dart';
// --- 导入组件 ---
import 'components/profile_widgets.dart';
import 'components/profile_cards.dart';
import 'academic_calender_page/academic_calendar_buttons.dart';
import '../database_helper.dart'; // 导入本地数据库助手

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // 根据分数百分比转换单科绩点 (Grade Point) 用作精确计算
  double _getGradePoint(dynamic gradeValue) {
    if (gradeValue == null) return -1.0; // 尚未产生最终成绩的科目不参与绩点计算

    double? marks = double.tryParse(gradeValue.toString());
    if (marks == null) return -1.0;

    if (marks >= 80) return 4.00;
    if (marks >= 75) return 3.67;
    if (marks >= 70) return 3.33;
    if (marks >= 65) return 3.00;
    if (marks >= 60) return 2.67;
    if (marks >= 55) return 2.33;
    if (marks >= 50) return 2.00;
    return 0.00; // F
  }

  // ✅ 核心动态合并与统计计算助手：完全不依赖 Students 表的非存在列
  Future<Map<String, dynamic>?> _loadFullProfileWithCalculations() async {
    final String currentUserId = DatabaseHelper.currentUserId;
    if (currentUserId.isEmpty) return null;

    final db = await DatabaseHelper.instance.database;

    // 1. 运行百分之百安全的联查语句，只获取客观存在的基本资料字段
    final List<Map<String, dynamic>> userRows = await db.rawQuery('''
      SELECT 
        u.User_ID, u.Name, u.Email, u.Phone, u.Role,
        p.Programme_Name, p.Faculty_ID
      FROM Users u
      LEFT JOIN Students s ON u.User_ID = s.Student_ID
      LEFT JOIN Programmes p ON s.Programme_ID = p.Programme_ID
      WHERE u.User_ID = ?
    ''', [currentUserId]);

    if (userRows.isEmpty) return null;
    final Map<String, dynamic> fullUserData = Map<String, dynamic>.from(userRows.first);

    // 2. 联合查询该生所有的学期选课学分、以及各科最终总分
    final List<Map<String, dynamic>> courseRecords = await db.rawQuery('''
      SELECT 
          s.Academic_Session,
          s.Semester,
          c.Course_Credits,
          r.Final_Grade
      FROM Courses_Enrollments ce
      JOIN Sections s ON ce.Section_ID = s.Section_ID
      JOIN Courses c ON s.Course_ID = c.Course_ID
      LEFT JOIN Results r ON ce.Course_Enrollment_ID = r.Course_Enrollment_ID
      WHERE ce.Student_ID = ?
      ORDER BY s.Academic_Session ASC, s.Semester ASC
    ''', [currentUserId]);

    int totalObtainedCredits = 0; // 累计已取得的学分 (及格的科目)
    int totalGradedCredits = 0;   // 参与总绩点计算的总学分
    double totalQualityPoints = 0.0; // 累计总质量分数点

    // 用一个 Map 按学期标签分组
    Map<String, List<Map<String, dynamic>>> semesterGroups = {};

    for (var row in courseRecords) {
      String semKey = "${row['Academic_Session']} S${row['Semester']}";
      if (!semesterGroups.containsKey(semKey)) {
        semesterGroups[semKey] = [];
      }
      semesterGroups[semKey]!.add(row);

      if (row['Final_Grade'] != null) {
        double marks = double.tryParse(row['Final_Grade'].toString()) ?? 0.0;
        int credits = int.tryParse(row['Course_Credits'].toString()) ?? 0;

        // 只要 Final Marks >= 50 就算作通过，累加至 Obtained Credits
        if (marks >= 50) {
          totalObtainedCredits += credits;
        }

        double gp = _getGradePoint(row['Final_Grade']);
        if (gp >= 0) {
          totalGradedCredits += credits;
          totalQualityPoints += (gp * credits);
        }
      }
    }

    // 3. 计算全局总平均绩点 (CGPA) -> 用于展示在 Current CGPA 上
    double calculatedCgpa = totalGradedCredits > 0 ? (totalQualityPoints / totalGradedCredits) : 0.0;

    // 4. 计算最新一个已经出了成绩的学期绩点 (GPA) -> 用于展示在 Current CPA 上
    double calculatedCcpa = 0.0;
    if (semesterGroups.isNotEmpty) {
      String latestSemesterKey = semesterGroups.keys.last;
      // 倒序寻找最新一个“已经拥有成绩”的学期标签，防止新开学期数据为空导致成绩归零
      for (String key in semesterGroups.keys.toList().reversed) {
        bool hasGrades = semesterGroups[key]!.any((course) => course['Final_Grade'] != null);
        if (hasGrades) {
          latestSemesterKey = key;
          break;
        }
      }

      List<Map<String, dynamic>> latestCourses = semesterGroups[latestSemesterKey]!;
      int semGradedCredits = 0;
      double semQualityPoints = 0.0;

      for (var course in latestCourses) {
        if (course['Final_Grade'] != null) {
          int credits = int.tryParse(course['Course_Credits'].toString()) ?? 0;
          double gp = _getGradePoint(course['Final_Grade']);
          if (gp >= 0) {
            semGradedCredits += credits;
            semQualityPoints += (gp * credits);
          }
        }
      }
      calculatedCcpa = semGradedCredits > 0 ? (semQualityPoints / semGradedCredits) : 0.0;
    }

    // 5. ✅ 对齐映射：对应 StatsRowBar 组件中的字段解析，类型严格限制为 double 和 int 数字型
    fullUserData['CGPA'] = calculatedCcpa;            // 映射到 "Current CPA"
    fullUserData['CCPA'] = calculatedCgpa;            // 映射到 "Current CGPA"
    fullUserData['Obtained_Credits'] = totalObtainedCredits; // 映射到 "Obtained Credit"
    fullUserData['Debt'] = "RM 0.00";                 // 财务账单占位符

    return fullUserData;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: FutureBuilder<Map<String, dynamic>?>(
          future: _loadFullProfileWithCalculations(),
          builder: (context, snapshot) {

            // 状态 A：加载中
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: colors.brandPrimary));
            }

            // 状态 B：发生意外异常
            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text(
                  'Unable to Load',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              );
            }

            // 状态 C：成功获取
            final userData = snapshot.data!;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -500, left: 0, right: 0, height: 500,
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

                          StatsRowBar(userData: userData),
                          const SizedBox(height: 12),

                          StudentDetailsCard(userData: userData),
                          const SizedBox(height: 12),

                          const NextOfKinCard(),
                          const SizedBox(height: 12),

                          const ContactUsCard(),
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
          }
      ),
    );
  }
}