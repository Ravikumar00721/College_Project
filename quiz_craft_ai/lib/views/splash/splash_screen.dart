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

  @override
  void initState() {
    super.initState();

    // Start fade-in effect
    Timer(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Check tutorial status and authentication state
    Timer(Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      bool seenTutorial = prefs.getBool("seen_tutorial") ?? false;
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (seenTutorial) {
          context.go('/home'); // ✅ User logged in & tutorial seen → Home
        } else {
          context.go(
              '/tutorial'); // ✅ User logged in & tutorial NOT seen → Tutorial
        }
      } else {
        if (seenTutorial) {
          context.go('/login'); // ✅ User NOT logged in & tutorial seen → Login
        } else {
          context.go(
              '/tutorial'); // ✅ User NOT logged in & tutorial NOT seen → Tutorial
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            Lottie.asset('assets/animations/splash.json', height: 300),
            SizedBox(height: 20),

            // Stylish Fade-in Text
            AnimatedOpacity(
              duration: Duration(seconds: 2),
              opacity: _opacity,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color.fromRGBO(255, 104, 11, 1.0), // Orange
                    Color.fromRGBO(255, 167, 38, 1.0), // Lighter orange
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  "QuizCraft AI",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
