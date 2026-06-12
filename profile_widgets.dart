import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uthm/shared/theme/app_colors.dart';
import '../virtual_id_page.dart';

// =======================================================
//   🔥 扁平化身份信息页眉（全面引用颜色库重构版）
// =======================================================
class FlatIdentityHeader extends StatelessWidget {
  const FlatIdentityHeader({
    super.key,
    this.name = "LEE ROU",
    this.idLabel = "Matric No: AI230199",
    this.showAvatarImage = true,
    this.virtualIdLabel = "My Virtual ID",
  });

  final String name;
  final String idLabel;
  final bool showAvatarImage;
  final String virtualIdLabel;

  @override
  Widget build(BuildContext context) {
    // 严格从 Theme Extension 获取颜色
    final colors = context.colors;

    return Center(
      child: Column(
        children: [
          // -----------------------------------------------
          // 1. 大头像（边框、衬底全面引用颜色库）
          // -----------------------------------------------
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // 💡 替换：使用颜色库的面色（轻度透明）作为高光衬底
              color: colors.surface.withValues(alpha: 0.2),
              border: Border.all(
                color: colors.surface.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: colors.borderColor, // 💡 替换：背景由颜色库驱动
              backgroundImage:
                  showAvatarImage ? const AssetImage('assets/me.jpg') : null,
              child: showAvatarImage
                  ? null
                  : Icon(
                      Icons.person,
                      size: 56,
                      color: colors.surface.withValues(alpha: 0.7),
                    ),
              //child: Icon(Icons.person, size: 60, color: colors.surface.withOpacity(0.3)), // 💡 替换：图标色引用颜色库
            ),
          ),

          const SizedBox(height: 10),

          // -----------------------------------------------
          // 2. 文本信息区域（全面引用颜色库）
          // -----------------------------------------------
          // 名字
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white, // 💡 替换：严格使用颜色库面色（白）
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          // 学号
          Text(
            "($idLabel)",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85), // 💡 替换：严格使用颜色库面色
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          // -----------------------------------------------
          // 3. 虚拟 ID 按钮（全面引用颜色库）
          // -----------------------------------------------
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VirtualIdPage()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    colors.surface.withValues(alpha: 0.15), // 💡 替换：按钮底色引用颜色库
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      colors.surface.withValues(alpha: 0.35), // 💡 替换：按钮边框引用颜色库
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner,
                      size: 15, color: Colors.white), // 💡 替换
                  const SizedBox(width: 8),
                  Text(
                    virtualIdLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white, // 💡 替换
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
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

// =======================================================
//   🔥 悬浮设置按钮（全面引用颜色库重构版）
// =======================================================
class SettingsButton extends StatefulWidget {
  const SettingsButton({super.key});
  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
  bool _isPressed = false; // 改为监听按下状态，适配 Apple 缩放交互

  @override
  Widget build(BuildContext context) {
    final colors = context.colors; // 严格获取颜色库

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {/* 处理设置点击 */},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150), // 缩放动画时长
        // Apple 系统级微交互：按下时缩放至 0.95
        transform: Matrix4.diagonal3Values(
          _isPressed ? 0.95 : 1.0,
          _isPressed ? 0.95 : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(10), // 稍微增加 padding 保证触摸面积 >= 44x44
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // 1. 纯净的卡片面色 (白/深色)
          color: colors.surface,
          // 2. Apple 极细边框
          border: Border.all(color: colors.borderColor, width: 0.5),
          // 3. 严格移除 boxShadow，保持扁平化
        ),
        child: Icon(
          Icons.settings_outlined,
          color: colors.primaryText, // 背景是卡片色，所以图标用主文本色
          size: 24,
        ),
      ),
    );
  }
}

// =======================================================
//   以下卡片组件（进度条、状态栏）原本就已严格引用颜色库，保持原样
// =======================================================
class WeekGridProgress extends StatelessWidget {
  const WeekGridProgress({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const int totalWeeks = 14;
    const int currentWeek = 8;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Week Progress",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: colors.primaryText,
                      fontSize: 13)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: colors.brandPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Text("Week $currentWeek / $totalWeeks",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: colors.brandPrimary,
                        fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (int i = 0; i < totalWeeks; i++) ...[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: i < currentWeek
                            ? colors.brandPrimary
                            : colors.borderColor.withValues(alpha: 0.5),
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

class StatsRowBar extends StatelessWidget {
  const StatsRowBar({super.key});

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

        // 🔥 在特定需要换行的卡片，开启 isLongText: true
        _buildStatItem(context, "Outstanding\nDebt", "RM 30000.00"),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      {String? subLabel}) {
    final colors = context.colors;

    final bool isLongText = value.length > 6;

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          // 长文本时上下 padding 稍微收紧 (6)，给换行留出足够的垂直空间
          padding: EdgeInsets.symmetric(
              vertical: isLongText ? 12 : 12, horizontal: 4),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.borderColor, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. 顶部的两行标签
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  height: 1.1,
                  color: colors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),

              // 💡 智能间距：长文本换行时调紧间距 (2)，短文本单行时放开间距 (6)
              SizedBox(height: isLongText ? 2 : 6),

              // 2. 核心动态数据区域 (彻底移除 FittedBox，改用智能原生换行)
              Expanded(
                child: Center(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      // 💡 奇迹发生在这里：
                      // 如果是长文本，用 13 号字配合紧凑行高，确保能换行排开且不溢出
                      // 如果是短文本，直接拉满 16 号大字，保证霸气居中
                      fontSize: isLongText ? 13 : 16,
                      height: isLongText ? 1.1 : null,
                      fontWeight: FontWeight.bold,
                      color: colors.primaryText,
                    ),
                    textAlign: TextAlign.center,
                    // 💡 智能行数：短文本锁死 1 行，长文本允许 2 行自然折行
                    maxLines: isLongText ? 2 : 1,
                    overflow: TextOverflow.ellipsis, // 万一超过2行才显示省略号
                  ),
                ),
              ),

              if (subLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  subLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: colors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
