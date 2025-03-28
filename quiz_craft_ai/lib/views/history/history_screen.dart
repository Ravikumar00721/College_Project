import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/quiz_result.dart'; // Add intl package to pubspec.yaml

class HistoryScreen extends StatelessWidget {
  final List<QuizResult> quizResults;

  const HistoryScreen({super.key, required this.quizResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
        centerTitle: true,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(
              Icons.arrow_back_ios_new_rounded), // Modern arrow style
          color: Colors.black87,
          iconSize: 24,
          onPressed: () => context.go('/home'),
          // Safer pop
        ),
      ),
      body: quizResults.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: quizResults.length,
              itemBuilder: (context, index) {
                final result = quizResults[index];
                return _buildQuizCard(result, context);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No Quiz History Yet!',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Complete your first quiz to see results here',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizResult result, BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          ),
        ),
        subtitle: Text(
          '${result.correctAnswers} Correct • ${result.totalQuestions - result.correctAnswers} Incorrect',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
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
                      color: Colors.grey[600],
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
                        color: Colors.grey[600],
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
