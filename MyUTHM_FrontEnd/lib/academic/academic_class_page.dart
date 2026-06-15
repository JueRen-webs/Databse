import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:uthm/main.dart';

import 'package:uthm/academic/tab_stream.dart';
import 'package:uthm/academic/tab_learning_materials.dart';
import 'package:uthm/academic/tab_pyq.dart';
import 'package:uthm/academic/tab_individual_activities.dart';
import 'package:uthm/academic/tab_group_activities.dart';
import 'package:uthm/academic/tab_assessment.dart';
import 'package:uthm/academic/tab_marks.dart';
import 'package:uthm/academic/tab_attendance.dart';
import 'package:uthm/academic/tab_lecturer_profile.dart';

const Color kHeaderColor = Color(0xFF001C55);
const Color kBorderColor = Color(0xFFEEEEEE);
const Color kLinkColor = Color(0xFFA93226);
const Color kPrimaryBlue = Color(0xFF0422A7);
const Color kStatusFull = Color(0xFFE53935);
const Color kStatusAvailable = Color(0xFF43A047);
const Color kNameBlue = Color(0xFF1976D2);
const Color kBackgroundColor = Color(0xFFF4F6FC);
const Color kCoordOrange = Color(0xFFEF6C00);
const Color kCoordBlue = Color(0xFF1565C0);
const Color kCoordGreen = Color(0xFF2E7D32);
const Color kCoordYellow = Color(0xFFFFCA28);
const Color kCoordInfo = Color(0xFF455A64);
const Color kTrashRed = Color(0xFFC62828);
const Color kSelectionBg = Color(0xFFE3F2FD);

class AcademicClassPage extends StatefulWidget {
  final Map<String, String> courseData;

  final bool isLecturer;

  final String initialTab;

  const AcademicClassPage({
    super.key,
    required this.courseData,
    this.isLecturer = false,
    this.initialTab = 'Stream',
  });

  @override
  State<AcademicClassPage> createState() => _AcademicPageState();
}

class _AcademicPageState extends State<AcademicClassPage> {
  late String _currentTab;
  bool _isSidebarExpanded = false;
  int _tabRefreshToken = 0;

  List<_TabItem> get _tabs => [
        const _TabItem('Stream', Icons.chat_bubble_outline),
        const _TabItem('Learning Materials', Icons.computer),
        const _TabItem('Past Year Questions', Icons.history),
        const _TabItem('Individual Activities', Icons.person_outline),
        const _TabItem('Group Activities', Icons.people_outline),
        const _TabItem('Assessment', Icons.quiz_outlined),
        const _TabItem('Marks', Icons.bar_chart),
        const _TabItem('Attendance', Icons.fact_check_outlined),
        if (!widget.isLecturer)
          const _TabItem('Lecturer Profile', Icons.badge_outlined),
      ];

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case 'Stream':
        return StreamTab(
          sectionId: widget.courseData['section_id'] ?? '',
          lecturerName: widget.courseData['lecturer'] ?? 'Lecturer',
          isLecturer: widget.isLecturer,
        );

      case 'Learning Materials':
        return LearningMaterialsTab(
          sectionId: widget.courseData['section_id'] ?? '',
          canManage: widget.isLecturer,
        );

      case 'Past Year Questions':
        return PastYearQuestionsTab(
          canManage: widget.isLecturer,
          isLecturer: widget.isLecturer,
          courseId: widget.courseData['code'] ?? 'UNKNOWN',
          sectionId: widget.courseData['section_id'] ?? '',
        );

      case 'Individual Activities':
        return IndividualActivitiesTab(
          key: ValueKey('individual-$_tabRefreshToken'),
          sectionId: widget.courseData['section_id'] ?? '',
          canManage: widget.isLecturer,
        );

      case 'Group Activities':
        return GroupActivitiesTab(
          key: ValueKey('group-$_tabRefreshToken'),
          sectionId: widget.courseData['section_id'] ?? '',
          canManage: widget.isLecturer,
        );

      case 'Assessment':
        return AssessmentTab(
          sectionId: widget.courseData['section_id'] ?? '',
          canManage: widget.isLecturer,
        );

      case 'Marks':
        return MarksTab(
          sectionId: widget.courseData['section_id'] ?? '',
          canManage: widget.isLecturer,
        );

      case 'Attendance':
        return AttendanceTab(
          key: ValueKey('attendance-$_tabRefreshToken'),
          isLecturer: widget.isLecturer,
          courseData: widget.courseData,
        );

      case 'Lecturer Profile':
        return LecturerProfileTab(
          sectionId: widget.courseData['section_id'] ?? '',
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.courseData['code'] ?? ''} : ${widget.courseData['name'] ?? ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: SizedBox(
        width: 75,
        height: 75,
        child: FloatingActionButton(
          onPressed: () {
            mainGlobalKey.currentState?.switchToTab(2);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          backgroundColor: kPrimaryBlue,
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
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.menu_book, 'Academic', 1),
            SizedBox(
              width: 54,
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'Scan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _buildNavItem(Icons.notifications_outlined, 'Notification', 3),
            _buildNavItem(Icons.person_outline, 'Profile', 4),
          ],
        ),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              _buildSidebar(expanded: false),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 16, right: 12, bottom: 16),
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
          if (_isSidebarExpanded) ...[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _isSidebarExpanded = false),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildSidebar(expanded: true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebar({required bool expanded}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: expanded ? 300 : 75,
      margin: const EdgeInsets.only(left: 12, top: 16, bottom: 16, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: expanded ? 0.12 : 0.05),
            blurRadius: expanded ? 24 : 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: _tabs
                    .map((t) =>
                        _buildSideItem(t.label, t.icon, expanded: expanded))
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _isSidebarExpanded = !expanded),
            child: Container(
              width: expanded ? 180 : 54,
              height: 54,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: expanded
                    ? kPrimaryBlue.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                expanded ? Icons.close : Icons.grid_view_rounded,
                color: kPrimaryBlue,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideItem(String label, IconData icon, {required bool expanded}) {
    final bool isActive = _currentTab == label;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        setState(() {
          if (_currentTab == label) {
            _tabRefreshToken++;
          }
          _currentTab = label;
          _isSidebarExpanded = false;
        });
      },
      child: Container(
        width: expanded ? 190 : 66,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? 12 : 6,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF4F7FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: expanded
            ? Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isActive ? kPrimaryBlue : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      color: isActive ? Colors.white : Colors.grey.shade500,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? kPrimaryBlue : Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isActive ? kPrimaryBlue : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      color: isActive ? Colors.white : Colors.grey.shade500,
                      size: 21,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _shortLabel(label),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive ? kPrimaryBlue : Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    const int activeIndex = 1;
    final bool isActive = index == activeIndex;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index != activeIndex) {
            mainGlobalKey.currentState?.switchToTab(index);
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isActive ? kPrimaryBlue : Colors.grey.shade500,
                size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? kPrimaryBlue : Colors.grey.shade500,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortLabel(String label) {
    const map = {
      'Stream': 'Stream',
      'Learning Materials': 'Material',
      'Past Year Questions': 'PYQ',
      'Individual Activities': 'Individual',
      'Group Activities': 'Group',
      'Assessment': 'Assess',
      'Marks': 'Marks',
      'Attendance': 'Attend',
      'Lecturer Profile': 'Lecturer',
    };
    return map[label] ?? label;
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem(this.label, this.icon);
}
