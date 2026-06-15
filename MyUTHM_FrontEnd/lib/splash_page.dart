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


  late Animation<double> _eyeJump;
  late Animation<double> _fadeIn;
  late Animation<Offset> _sloganSlide;
  late Animation<double> _bgScale;
  late Animation<double> _bgRotate;
  late Animation<double> _bgOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );


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


    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );


    _sloganSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic)),
    );


    _bgScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _bgRotate = Tween<double>(begin: 0.0, end: 0.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _bgOpacity = Tween<double>(begin: 0.03, end: 0.09).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _controller.forward();
    _startLoading();
  }

  Future<void> _startLoading() async {

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





              Positioned(
                top: -120,
                right: -100,
                child: Transform.rotate(
                  angle: _bgRotate.value,
                  child: Transform.scale(
                    scale: _bgScale.value,
                    child: Opacity(
                      opacity: _bgOpacity.value,
                      child: const Icon(Icons.circle_outlined, size: 450, color: primaryBlue),
                    ),
                  ),
                ),
              ),


              Positioned(
                bottom: -100,
                left: -120,
                child: Transform.rotate(
                  angle: -_bgRotate.value,
                  child: Transform.scale(
                    scale: _bgScale.value * 0.9,
                    child: Opacity(
                      opacity: _bgOpacity.value * 0.8,
                      child: const Icon(Icons.circle_outlined, size: 500, color: primaryBlue),
                    ),
                  ),
                ),
              ),




              Center(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [

                          Image.asset('assets/logo_body.png', width: 220),

                          Transform.translate(
                            offset: Offset(0, _eyeJump.value),
                            child: Image.asset('assets/logo_dots.png', width: 220),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),


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