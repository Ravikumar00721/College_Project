import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.8;
  double _textScale = 0.95;

  @override
  void initState() {
    super.initState();

    // Start animations
    Timer(Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
        _textScale = 1.0;
      });
    });

    // Check tutorial status and authentication state
    Timer(Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      bool seenTutorial = prefs.getBool("seen_tutorial") ?? false;
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        context.go(seenTutorial ? '/home' : '/tutorial');
      } else {
        context.go(seenTutorial ? '/login' : '/tutorial');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFFF3E0),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Lottie with scaling
              AnimatedScale(
                scale: _scale,
                duration: Duration(seconds: 1),
                curve: Curves.elasticOut,
                child: Lottie.asset(
                  'assets/animations/splash.json',
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 30),

              // Main title with multiple effects
              AnimatedOpacity(
                duration: Duration(seconds: 1),
                opacity: _opacity,
                child: AnimatedScale(
                  scale: _textScale,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOutBack,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Text shadow for depth
                      Text(
                        "QuizCraft AI",
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 6
                            ..color = Colors.black.withOpacity(0.1),
                        ),
                      ),
                      // Gradient text
                      ShaderMask(
                        shaderCallback: (bounds) => RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.5,
                          colors: [
                            Color(0xFFFF7043), // Deep orange
                            Color(0xFFFFA726), // Amber
                            Color(0xFFFFCA28), // Yellow
                          ],
                          tileMode: TileMode.mirror,
                        ).createShader(bounds),
                        child: Text(
                          "QuizCraft AI",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Subtitle with fade-in
              AnimatedOpacity(
                opacity: _opacity,
                duration: Duration(milliseconds: 1500),
                child: Text(
                  "Transform Learning with AI",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 40),

              // Loading indicator with color transition
              AnimatedOpacity(
                opacity: _opacity,
                duration: Duration(milliseconds: 1000),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFA726),
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
