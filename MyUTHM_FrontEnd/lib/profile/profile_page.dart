import 'package:flutter/material.dart';
import 'package:uthm/theme/app_colors.dart';
import '../logout_page.dart';
// --- 导入组件 ---
import 'components/profile_widgets.dart';
import 'components/profile_cards.dart';
import 'academic_calender_page/academic_calendar_buttons.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      // 🔥 核心修改：直接将 SingleChildScrollView 作为 body，去掉外层的 Stack 钉子
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(), // 只能往下滑动，不向上拉伸
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. 顶部安全区域底色补丁
            Positioned(
              top: -500, left: 0, right: 0, height: 500,
              child: Container(color: colors.brandPrimary),
            ),

            // 2. 蓝色区块背景 (360高度 + 32px弧度)
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

            // 3. 主体 UI 内容排版
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25), // 顶部紧凑留白

                    const FlatIdentityHeader(),

                    const SizedBox(height: 15), // 弧边与下方卡片的精准间距

                    const WeekGridProgress(),
                    const SizedBox(height: 12),

                    const StatsRowBar(),
                    const SizedBox(height: 12),

                    const StudentDetailsCard(),
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

            // ==========================================
            // 🔥 4. 设置按钮 (现在它被放进了滑动的 Stack 内部)
            // 它被放置在蓝色背景的右上角，当你往下滑，它就会跟着滑走！
            // ==========================================
            Positioned(
              top: MediaQuery.of(context).padding.top + 12, // 距离屏幕顶部的安全距离
              right: 20,
              child: const SettingsButton(),
            ),
          ],
        ),
      ),
    );
  }
}