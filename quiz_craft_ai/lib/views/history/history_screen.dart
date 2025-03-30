import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/quiz_result.dart';
import '../../providers/theme_provider.dart';

class HistoryScreen extends ConsumerWidget {
  final List<QuizResult> quizResults;

  const HistoryScreen({super.key, required this.quizResults});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeProvider.notifier).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
        centerTitle: true,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
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
      body: quizResults.isEmpty
          ? _buildEmptyState(isDarkMode)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: quizResults.length,
              itemBuilder: (context, index) {
                final result = quizResults[index];
                return _buildQuizCard(result, context, isDarkMode);
              },
            ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 80,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No Quiz History Yet!',
            style: TextStyle(
              fontSize: 20,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Complete your first quiz to see results here',
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(
      QuizResult result, BuildContext context, bool isDarkMode) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getScoreColor(result.score).withOpacity(0.2),
          child: Text(
            '${result.score}%',
            style: TextStyle(
              color: _getScoreColor(result.score),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          dateFormat.format(result.timestamp),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          '${result.correctAnswers} Correct • ${result.totalQuestions - result.correctAnswers} Incorrect',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        iconColor: isDarkMode ? Colors.white : Colors.black87,
        collapsedIconColor: isDarkMode ? Colors.white : Colors.black87,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[300]),
                const SizedBox(height: 8),
                ...List.generate(result.quizzes.length, (index) {
                  final quiz = result.quizzes[index];
                  final userAnswer = result.userAnswers[index];
                  final isCorrect = userAnswer == quiz.correctOptionIndex;

                  return _buildQuestionResult(
                    question: quiz.question,
                    userAnswer: quiz.options[userAnswer ?? 0],
                    correctAnswer: quiz.options[quiz.correctOptionIndex],
                    isCorrect: isCorrect,
                    isDarkMode: isDarkMode,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionResult({
    required String question,
    required String userAnswer,
    required String correctAnswer,
    required bool isCorrect,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect
              ? Colors.green.withOpacity(isDarkMode ? 0.5 : 0.3)
              : Colors.red.withOpacity(isDarkMode ? 0.5 : 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: 'Your Answer: '),
                      TextSpan(
                        text: userAnswer,
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.check, size: 18, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                        fontSize: 14,
                      ),
                      children: [
                        const TextSpan(text: 'Correct Answer: '),
                        TextSpan(
                          text: correctAnswer,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
