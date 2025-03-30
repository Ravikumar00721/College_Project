import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_craft_ai/views/quiz/quiz_screen.dart';

// Import Screens
import '../models/quiz_result.dart';
import '../services/auth_services.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/history/history_screen.dart';
import '../views/home/home_screen.dart';
import '../views/leaderboard/leaderboard.dart';
import '../views/profile/profile_edit_sheet.dart';
import '../views/profile/profile_screen.dart';
import '../views/splash/splash_screen.dart';
import '../views/tutorial/tutorial_screen.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final GoRouter router = GoRouter(
  initialLocation: "/", // Start with Splash Screen
  routes: [
    GoRoute(path: "/", builder: (context, state) => SplashScreen()),
    GoRoute(
        path: "/tutorial", builder: (context, state) => WalkthroughScreen()),
    GoRoute(path: "/login", builder: (context, state) => LoginInPage()),
    GoRoute(path: "/signup", builder: (context, state) => const SignUpPage()),
    GoRoute(path: "/home", builder: (context, state) => HomeScreen()),
    GoRoute(
        path: "/leaderboard", builder: (context, state) => LeaderboardScreen()),
    GoRoute(
        path: "/myprofile",
        builder: (context, state) => const MyProfileScreen()),
    GoRoute(
      path: "/history",
      builder: (context, state) {
        // Get the ProviderContainer from context
        final container = ProviderScope.containerOf(context);
        final authService = container.read(authServiceProvider);

        return FutureBuilder<List<QuizResult>>(
          future: authService.getQuizResults(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error loading history: ${snapshot.error}'));
            }
            return HistoryScreen(
              quizResults: snapshot.data ?? [],
            );
          },
        );
      },
    ),
    GoRoute(
        path:
            "/generate-quiz/:documentId", // Use a dynamic route parameter for documentId
        builder: (context, state) {
          final documentId = state.pathParameters['documentId']!;
          print("Document ID is : $documentId");
          return QuizScreen(
              documentId: documentId); // Pass documentId to QuizScreen
        }),

    // 🔹 Profile Edit Sheet as a Full Screen Page
    GoRoute(
      path: "/myprofileedit",
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text("Edit Profile"),
          centerTitle: true,
          leading: const BackButton(),
        ),
        body: ProfileEditSheet(onUpdate: () {}),
      ),
    ),
  ],
);
