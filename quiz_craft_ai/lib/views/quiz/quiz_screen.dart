// quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_craft_ai/views/quiz/quiz_view.dart';

import '../../providers/quiz_provider.dart';
import '../../widgets/bouncing.dart';

class QuizScreen extends ConsumerWidget {
  final String documentId;

  const QuizScreen({Key? key, required this.documentId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsyncValue = ref.watch(quizProvider(documentId));

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
      ),
      body: quizAsyncValue.when(
        data: (quizzes) => QuizView(quizzes: quizzes),
        loading: () => const Center(
            child: BouncingDotsLoader(
          color: Colors.blue, // Customize color
          dotSize: 20, // Customize dot size
          duration: Duration(milliseconds: 800), // Customize animation speed
        )),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
