import 'package:flutter/material.dart';
import 'package:uthm/theme/app_colors.dart';
import '../logout_page.dart';
// --- 导入组件 ---
import 'components/profile_widgets.dart';
import 'components/profile_cards.dart';
import 'academic_calender_page/academic_calendar_buttons.dart';
import '../database_helper.dart'; // 🔥 导入你的本地数据库助手

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      // 🔥 核心修改 1：用 FutureBuilder 包裹主体，去数据库拉取资料
      body: FutureBuilder<Map<String, dynamic>?>(
          future: DatabaseHelper.instance.getStudentProfile(DatabaseHelper.currentUserId),
          builder: (context, snapshot) {

            // 状态 A：还在查询数据库，显示加载圈圈
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: colors.brandPrimary));
            }

            // 状态 B：查询失败或找不到数据
            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('无法加载用户资料'));
            }

            // 状态 C：成功拿到完整的用户数据！
            final userData = snapshot.data!;

            // 👇 下面全是你原本完美的 UI 结构，100% 还原！
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

                          // 🔥 核心修改 2：把 userData 传进需要显示资料的组件里
                          // (注意：你需要去修改 FlatIdentityHeader 接收这个参数)
                          FlatIdentityHeader(userData: userData),

                          const SizedBox(height: 15),

                          const WeekGridProgress(),
                          const SizedBox(height: 12),

                          // 🔥 传给分数的 Bar
                          StatsRowBar(userData: userData),
                          const SizedBox(height: 12),

                          // 🔥 传给详细资料卡片
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