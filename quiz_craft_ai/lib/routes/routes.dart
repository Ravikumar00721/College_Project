import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_craft_ai/views/quiz/quiz_screen.dart';

// Import Screens
import '../models/quizmodel.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/history/history_screen.dart';
import '../views/home/home_screen.dart';
import '../views/profile/profile_edit_sheet.dart';
import '../views/profile/profile_screen.dart';
import '../views/splash/splash_screen.dart';
import '../views/tutorial/tutorial_screen.dart';

final quiz = QuizModel(
  id: '1',
  question: 'What is the capital of France?',
  options: ['Berlin', 'Madrid', 'Paris', 'Rome'],
  correctOptionIndex: 2,
  explanation: 'Paris is the capital of France.',
);

final GoRouter router = GoRouter(
  initialLocation: "/", // Start with Splash Screen
  routes: [
    GoRoute(path: "/", builder: (context, state) => SplashScreen()),
    GoRoute(
        path: "/tutorial", builder: (context, state) => WalkthroughScreen()),
    GoRoute(path: "/login", builder: (context, state) => LoginInPage()),
    GoRoute(path: "/signup", builder: (context, state) => SignUpPage()),
    GoRoute(path: "/home", builder: (context, state) => HomeScreen()),
    GoRoute(path: "/myprofile", builder: (context, state) => MyProfileScreen()),
    GoRoute(path: "/history", builder: (context, state) => HistoryScreen()),
    GoRoute(
        path: "/generate-quiz",
        builder: (context, state) => QuizScreen(quiz: quiz)),

    // 🔹 Profile Edit Sheet as a Full Screen Page
    GoRoute(
      path: "/myprofileedit",
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text("Edit Profile"),
          centerTitle: true,
          leading: BackButton(),
        ),
        body: ProfileEditSheet(onUpdate: () {}),
      ),
    ),
  ],
);
