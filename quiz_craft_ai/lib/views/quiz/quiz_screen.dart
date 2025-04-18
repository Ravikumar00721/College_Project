// quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_craft_ai/views/quiz/quiz_view.dart';

import '../../providers/quiz_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/bouncing.dart';

class QuizScreen extends ConsumerWidget {
  final String documentId;
  final String selectedSubCategory;
  final String selectedSubject;

  const QuizScreen({
    Key? key,
    required this.documentId,
    required this.selectedSubCategory,
    required this.selectedSubject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsyncValue = ref.watch(quizProvider(documentId));
    final isDarkMode = ref.watch(themeProvider.notifier).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Challenge'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
              color: Colors.white,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: quizAsyncValue.when(
        data: (quizzes) => QuizView(
          quizzes: quizzes,
          selectedSubCategory: selectedSubCategory!,
          selectedSubject: selectedSubject!,
        ),
        loading: () => const Center(
            child: BouncingDotsLoader(
          color: Colors.blue,
          dotSize: 20,
          duration: Duration(milliseconds: 800),
        )),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
