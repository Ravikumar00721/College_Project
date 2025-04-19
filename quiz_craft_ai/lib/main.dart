import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_craft_ai/providers/theme_provider.dart';
import 'package:quiz_craft_ai/routes/routes.dart';

import 'core/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    runApp(ProviderScope(child: MyApp()));
  } catch (e, stackTrace) {
    print("Firebase initialization error: $e");
    print("StackTrace: $stackTrace");
  }
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeMode,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: brightness == Brightness.light
            ? AppColors.primary
            : AppColors.darkPrimary,
        secondary: brightness == Brightness.light
            ? AppColors.secondary
            : AppColors.darkSecondary,
        background: brightness == Brightness.light
            ? AppColors.background
            : AppColors.darkBackground,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: brightness == Brightness.light
              ? AppColors.textPrimary
              : AppColors.darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          color: brightness == Brightness.light
              ? AppColors.textSecondary
              : AppColors.darkTextSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.light
            ? AppColors.primary
            : AppColors.darkPrimary,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            brightness == Brightness.light ? Colors.white : Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
