/*import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// --- 全局配置与主题引入 ---
import '../main.dart';
import 'package:uthm/theme/app_colors.dart';

// --- 独立页面引入 ---
import 'academic_calendar_page.dart';
import 'virtual_id_page.dart';

// =======================================================
//           CLASS 1: PROFILE PAGE (Main Tab)
// =======================================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Helper function to open the website
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background, // 保持全局底层是背景色
      // 最外层使用 Stack，用于分离“滑动内容”和“固定悬浮按钮”
      body: Stack(
        children: [
          // ==========================================
          // 图层 1：可滑动的主体内容（包含背景）
          // ==========================================
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Stack(
              clipBehavior: Clip.none, // 核心技巧：允许超出边界的绘制，用来掩盖下拉白边
              children: [
                // 核心修复：在页面的正上方（-1000的高度）画一个纯蓝色的背景。
                // 这样当你用力往下拉（回弹）时，露出来的全都是这个蓝色，再也不会有白底了！
                Positioned(
                  top: -1000,
                  left: 0,
                  right: 0,
                  height: 1000,
                  child: Container(color: colors.brandPrimary),
                ),

                // 跟着页面一起滑动的渐变背景
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [colors.brandPrimary, colors.background],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),

                // 滑动的主体内容
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 给右上角的悬浮设置按钮留出足够的空间，防止名片顶上去被挡住
                        const SizedBox(height: 60),

                        // --- 1. 名片卡片 ---
                        const _GlassIdentityCard(),
                        const SizedBox(height: 18),

                        // --- 2. 14格周进度 ---
                        const _WeekGridProgress(),
                        const SizedBox(height: 18),

                        // --- 3. 四合一数据栏 ---
                        const _StatsRowBar(),
                        const SizedBox(height: 18),

                        // --- 4. Student Details Card ---
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: _buildCardDecoration(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Student Details", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: colors.primaryText)),
                              const SizedBox(height: 16),

                              _buildInfoRow(
                                context,
                                Icons.domain,
                                "Faculty",
                                "FSKTM",
                                onTap: () => _launchURL("https://fsktm.uthm.edu.my/"),
                              ),
                              Divider(height: 30, color: colors.borderColor),
                              _buildInfoRow(context, Icons.school, "Course", "Bachelor of Computer Science\n(Multimedia Computing)"),
                              Divider(height: 30, color: colors.borderColor),
                              _buildInfoRow(context, Icons.email_outlined, "Email", "ai248888@student.uthm.edu.my"),
                              Divider(height: 30, color: colors.borderColor),
                              _buildInfoRow(context, Icons.phone_iphone, "Phone", "+60 12-345 6789"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // --- 5. 紧急联系人 (Next of Kin) ---
                        Container(
                          decoration: _buildCardDecoration(context),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Icon(Icons.group_outlined, color: colors.error, size: 28),
                              title: Text(
                                "Next of Kin (Emergency)",
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: colors.primaryText),
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              children: [
                                Divider(height: 1, color: colors.borderColor),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: colors.cardAlt,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: colors.borderColor)
                                  ),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Lee Kah", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: colors.primaryText)),
                                        const SizedBox(height: 8),
                                        _buildContactRow(context, Icons.supervised_user_circle, "Relationship: Guardian"),
                                        _buildContactRow(context, Icons.phone, "+60 17-999 8888"),
                                      ]
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // --- 6. Contact Us ---
                        Container(
                          decoration: _buildCardDecoration(context),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: Icon(
                                Icons.support_agent,
                                color: colors.brandPrimary,
                                size: 28,
                              ),
                              title: Text(
                                "Contact Us",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primaryText,
                                ),
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              children: [
                                Divider(height: 1, color: colors.borderColor),
                                const SizedBox(height: 20),
                                _buildContactCard(
                                  context,
                                  deptName: "Universiti Tun Hussein Onn Malaysia (UTHM)",
                                  address: "86400 Parit Raja Batu Pahat Johor\nMalaysia",
                                  phone: "+607-453 7000",
                                  fax: "+607-453 6337",
                                  email: "pro@uthm.edu.my",
                                  web: "http://www.uthm.edu.my",
                                ),
                                const SizedBox(height: 16),
                                _buildSectionSubLabel(context, "Postgraduate (Master & PhD)"),
                                _buildContactCard(
                                  context,
                                  deptName: "Centre for Graduate Studies",
                                  address: "86400 Parit Raja Batu Pahat Johor",
                                  phone: "+607-453 7757 / 7509",
                                  fax: "+607-453 6111",
                                  email: "ps@uthm.edu.my",
                                  web: "http://cgs.uthm.edu.my",
                                ),
                                const SizedBox(height: 16),
                                _buildSectionSubLabel(context, "Undergraduate (Diploma & Degree)"),
                                _buildContactCard(
                                  context,
                                  deptName: "Academic Management Office",
                                  address: "86400 Parit Raja Batu Pahat Johor",
                                  phone: "+607-453 7696",
                                  fax: "+607-453 6085",
                                  email: "pa@uthm.edu.my",
                                  web: "http://ppa.uthm.edu.my",
                                ),
                                const SizedBox(height: 16),
                                _buildSectionSubLabel(context, "International Student"),
                                _buildContactCard(
                                  context,
                                  deptName: "International Office",
                                  address: "86400 Parit Raja Batu Pahat Johor",
                                  phone: "+607-453 8514 / 8515",
                                  fax: "+607-453 8516",
                                  email: "io@uthm.edu.my",
                                  web: "http://io.uthm.edu.my",
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- 7. Action Buttons Area ---
                        Column(
                          children: [
                            _buildActionButton(
                              context,
                              "Academic Calendar",
                              Icons.calendar_month,
                              isPrimary: false,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AcademicCalendarPage()),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildLogoutButton(context),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // 图层 2：固定在右上角的设置按钮 (悬浮窗)
          // ==========================================
          Positioned(
            // 高度由 SafeArea 的顶部距离 + 16 决定，不会被刘海挡住，也不会贴着最顶上
            top: MediaQuery.of(context).padding.top + 16,
            // 距离右边框 20，不会太贴边缘
            right: 20,
            child: const _SettingsButton(),
          ),
        ],
      ),
    );
  }

  // =======================================================
  // --- Helper Methods ---
  // =======================================================

  BoxDecoration _buildCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))],
    );
  }

  Widget _buildSectionSubLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.brandPrimary)),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {VoidCallback? onTap}) {
    final colors = context.colors;
    Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: colors.brandPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: colors.brandPrimary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: colors.secondaryText)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onTap != null ? colors.brandPrimary : colors.primaryText,
                    decoration: onTap != null ? TextDecoration.underline : null,
                    decorationColor: colors.brandPrimary,
                  )),
            ],
          ),
        ),
        if (onTap != null) Icon(Icons.open_in_new, size: 16, color: colors.brandPrimary),
      ],
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: row);
    }
    return row;
  }

  Widget _buildContactCard(BuildContext context, {required String deptName, required String address, required String phone, required String fax, required String email, required String web}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.colors.cardAlt, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.colors.borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(deptName, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: context.colors.primaryText)),
        const SizedBox(height: 8),
        _buildContactRow(context, Icons.location_on, address),
        _buildContactRow(context, Icons.phone, phone),
        _buildContactRow(context, Icons.email, email),
      ]),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: context.colors.brandPrimary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12, color: context.colors.primaryText))),
      ]),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, {required bool isPrimary, required VoidCallback onTap}) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: isPrimary ? Colors.white : colors.brandPrimary),
        label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isPrimary ? Colors.white : colors.brandPrimary, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? colors.brandPrimary : colors.surface,
          side: isPrimary ? null : BorderSide(color: colors.brandPrimary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text("Log Out", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Do you want to quit this app?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              mainGlobalKey.currentState?.logout();
            },
            child: Text("Yes", style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }
}

// =======================================================
//   下方是独立的新 UI 组件
// =======================================================

// --- 带有光圈和 Hover 效果的专属设置按钮 ---
class _SettingsButton extends StatefulWidget {
  const _SettingsButton();

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () {
          // 在这里加入你的 Settings 点击事件
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // 悬停时背景变得更白
            color: _isHovering ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.15),
            border: Border.all(
              // 悬停时边框高亮
              color: Colors.white.withOpacity(_isHovering ? 0.8 : 0.4),
              width: 1.5,
            ),
            boxShadow: _isHovering ? [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
            ] : [],
          ),
          child: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// --- 玻璃拟物化身份卡片 ---
class _GlassIdentityCard extends StatelessWidget {
  const _GlassIdentityCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VirtualIdPage()),
        );
      },
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colors.background,
                      backgroundImage: const AssetImage('assets/me.jpg'),
                    ),
                    const SizedBox(height: 8),
                    Text("LEE ROU", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: colors.brandPrimary)),
                    const SizedBox(height: 2),
                    Text("Matrics No: AI230199", style: GoogleFonts.poppins(fontSize: 12, color: colors.brandPrimary.withOpacity(0.8))),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.brandPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_2, size: 14, color: colors.brandPrimary),
                          const SizedBox(width: 4),
                          Text("My Virtual ID", style: GoogleFonts.poppins(fontSize: 11, color: colors.brandPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 14格独立小圆角正方形周进度 ---
class _WeekGridProgress extends StatelessWidget {
  const _WeekGridProgress();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const int totalWeeks = 14;
    const int currentWeek = 8;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Week Progress", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: colors.primaryText, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Week $currentWeek / $totalWeeks",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colors.brandPrimary, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              for (int i = 0; i < totalWeeks; i++) ...[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: i < currentWeek ? colors.brandPrimary : colors.borderColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                if (i < totalWeeks - 1) const SizedBox(width: 5),
              ]
            ],
          ),
        ],
      ),
    );
  }
}

// --- 四合一数据栏 ---
class _StatsRowBar extends StatelessWidget {
  const _StatsRowBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(context, "Current\nCPA", "3.85"),
        const SizedBox(width: 12),
        _buildStatItem(context, "Current\nGPA", "3.90"),
        const SizedBox(width: 12),
        _buildStatItem(context, "Obtained\nCredit", "70/122"),
        const SizedBox(width: 12),
        _buildStatItem(context, "Current\nSession","Y2S2"),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, {String? subLabel}) {
    final colors = context.colors;
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 9, height: 1.1, color: colors.secondaryText, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 2
              ),
              const SizedBox(height: 2),
              Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: colors.primaryText),
                  textAlign: TextAlign.center,
                  maxLines: 1
              ),
              if (subLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                    subLabel,
                    style: GoogleFonts.poppins(fontSize: 9, color: colors.secondaryText, fontWeight: FontWeight.w500)
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}*/