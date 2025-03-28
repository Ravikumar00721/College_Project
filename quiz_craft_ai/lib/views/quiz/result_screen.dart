import 'package:confetti/confetti.dart'; // Add this package to pubspec.yaml
import 'package:flutter/material.dart';

import '../../models/quizmodel.dart';

class ResultScreen extends StatefulWidget {
  final List<QuizModel> quizzes;
  final int correctAnswers;
  final List<int?> userAnswers;

  const ResultScreen({
    super.key,
    required this.quizzes,
    required this.correctAnswers,
    required this.userAnswers,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = (widget.correctAnswers / widget.quizzes.length * 100).round();
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Score Circle
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _getScoreGradient(score),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getScoreColor(score).withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score%',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 42,
                            ),
                          ),
                          Text(
                            'SCORE',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Score Text with Celebration
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getScoreIcon(score),
                      color: _getScoreColor(score),
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _getScoreMessage(score),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(score),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Correct Answers Chip
                Chip(
                  backgroundColor: _getScoreColor(score).withOpacity(0.2),
                  label: Text(
                    '${widget.correctAnswers}/${widget.quizzes.length} Correct Answers',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Results List Header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Detailed Results:',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Enhanced Results List
                Expanded(
                  child: ListView.separated(
                    itemCount: widget.quizzes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final quiz = widget.quizzes[index];
                      final isCorrect =
                          widget.userAnswers[index] == quiz.correctOptionIndex;

                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isCorrect
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            width: 2,
                          ),
                        ),
                        child: ExpansionTile(
                          leading: Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: isCorrect ? Colors.green : Colors.red,
                            size: 28,
                          ),
                          title: Text(
                            quiz.question,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildAnswerRow(
                                      'Your Answer:',
                                      quiz.options[
                                          widget.userAnswers[index] ?? 0],
                                      isCorrect ? Colors.green : Colors.red),
                                  const SizedBox(height: 8),
                                  _buildAnswerRow(
                                      'Correct Answer:',
                                      quiz.options[quiz.correctOptionIndex],
                                      Colors.green),
                                  if (quiz.explanation != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      'Explanation:',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      quiz.explanation!,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Back to Home Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Back to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getScoreColor(score).withOpacity(0.9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),

          // Confetti Effect
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerRow(String label, String answer, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            answer,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getScoreGradient(int score) {
    if (score >= 80) return [Colors.green, Colors.lightGreenAccent];
    if (score >= 50) return [Colors.orange, Colors.amberAccent];
    return [Colors.red, Colors.redAccent];
  }

  IconData _getScoreIcon(int score) {
    if (score >= 90) return Icons.emoji_events;
    if (score >= 70) return Icons.star_rounded;
    if (score >= 50) return Icons.thumb_up;
    return Icons.auto_awesome;
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return 'Outstanding!';
    if (score >= 70) return 'Fantastic!';
    if (score >= 50) return 'Good Effort!';
    return 'Keep Trying!';
  }
}
