import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:uthm/login_page.dart'; 

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // 核心动画定义
  late Animation<double> _eyeJump;
  late Animation<double> _fadeIn;
  late Animation<Offset> _sloganSlide;
  late Animation<double> _bgScale;    // 背景缩放
  late Animation<double> _bgRotate;   // 背景微旋
  late Animation<double> _bgOpacity;  // 背景明暗变化

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // 1. 眼睛弹跳两次逻辑 (保持原有生动效果)
    _eyeJump = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -40.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -40.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -15.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -15.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    // 2. 整个内容的渐现
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    // 3. Slogan 向上浮现动效
    _sloganSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic)),
    );

    // 4. 背景呼吸感：缩放 + 旋转 + 明暗 (Opacity)
    _bgScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _bgRotate = Tween<double>(begin: 0.0, end: 0.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    // 明暗变化：从极淡 (0.03) 到稍微清晰 (0.08)
    _bgOpacity = Tween<double>(begin: 0.03, end: 0.09).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.forward();
    _startLoading();
  }

  Future<void> _startLoading() async {
    // 停留 4.5 秒确保动画完整
    await Future.delayed(const Duration(milliseconds: 4500));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0022BA);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 246, 252),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // ---------------------------------------------------------
              // 背景装饰层：带缩放、旋转、明暗动效的圆环
              // ---------------------------------------------------------
              
              // 右上角背景圆
              Positioned(
                top: -120,
                right: -100,
                child: Transform.rotate(
                  angle: _bgRotate.value,
                  child: Transform.scale(
                    scale: _bgScale.value,
                    child: Opacity(
                      opacity: _bgOpacity.value, // 动态明暗
                      child: const Icon(Icons.circle_outlined, size: 450, color: primaryBlue),
                    ),
                  ),
                ),
              ),
              
              // 左下角背景圆 (纯净圆圈)
              Positioned(
                bottom: -100,
                left: -120,
                child: Transform.rotate(
                  angle: -_bgRotate.value, // 反向微旋
                  child: Transform.scale(
                    scale: _bgScale.value * 0.9,
                    child: Opacity(
                      opacity: _bgOpacity.value * 0.8, // 动态明暗，比右上角稍暗一点产生空间感
                      child: const Icon(Icons.circle_outlined, size: 500, color: primaryBlue),
                    ),
                  ),
                ),
              ),
              
              // ---------------------------------------------------------
              // 内容主体层
              // ---------------------------------------------------------
              Center(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Logo 主体
                          Image.asset('assets/logo_body.png', width: 220),
                          // 弹跳两次的眼睛
                          Transform.translate(
                            offset: Offset(0, _eyeJump.value),
                            child: Image.asset('assets/logo_dots.png', width: 220),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                      
                      // Slogan 动画展示
                      SlideTransition(
                        position: _sloganSlide,
                        child: Column(
                          children: [
                            Text(
                              "EMPOWERING YOUR CAMPUS LIFE",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // 红色线条装饰
                            Container(
                              height: 2.5, 
                              width: 40, 
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}