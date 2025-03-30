import 'package:flutter/material.dart';
import 'package:quiz_craft_ai/views/quiz/result_screen.dart';

import '../../models/quizmodel.dart';
import '../../services/auth_services.dart';
import '../../widgets/bouncing.dart';

class QuizView extends StatefulWidget {
  final List<QuizModel> quizzes;

  const QuizView({Key? key, required this.quizzes}) : super(key: key);

  @override
  _QuizViewState createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerSubmitted = false;
  bool _isLoading = false;

  QuizModel get currentQuiz => widget.quizzes[_currentQuestionIndex];
  bool get hasNextQuestion => _currentQuestionIndex < widget.quizzes.length - 1;
  Future<void> _finishQuiz() async {
    try {
      setState(() => _isLoading = true);

      final correctAnswers = widget.quizzes
          .where((quiz) =>
              _userAnswers[widget.quizzes.indexOf(quiz)] ==
              quiz.correctOptionIndex)
          .length;

      await AuthService().saveQuizResult(
        quizzes: widget.quizzes,
        correctAnswers: correctAnswers,
        userAnswers: _userAnswers.values.toList(),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            quizzes: widget.quizzes,
            correctAnswers: correctAnswers,
            userAnswers: _userAnswers.values.toList(),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting quiz: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionCount(theme),
            _buildQuestionCard(theme, isDarkMode),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: currentQuiz.options.length,
                separatorBuilder: (context, index) => Divider(
                  color: theme.dividerColor,
                  height: 8,
                ),
                itemBuilder: (context, index) =>
                    _buildOptionButton(index, theme, isDarkMode),
              ),
            ),
            const SizedBox(height: 16),
            _buildControlButton(theme),
            if (_isAnswerSubmitted) _buildResultSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCount(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        'Question ${_currentQuestionIndex + 1} of ${widget.quizzes.length}',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(ThemeData theme, bool isDarkMode) {
    return SizedBox(
      width: double.infinity, // Force full width
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: isDarkMode ? theme.cardColor : Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity, // Double ensure full width
            child: Text(
              currentQuiz.question,
              style: theme.textTheme.titleLarge?.copyWith(
                color:
                    isDarkMode ? theme.colorScheme.onSurface : Colors.blueGrey,
              ),
              softWrap: true, // Ensure text wraps properly
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index, ThemeData theme, bool isDarkMode) {
    final option = currentQuiz.options[index];
    final isCorrect = index == currentQuiz.correctOptionIndex;
    final isSelected = index == _selectedOptionIndex;
    final showAnswer = _isAnswerSubmitted;

    return InkWell(
      onTap: !_isAnswerSubmitted
          ? () => setState(() => _selectedOptionIndex = index)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: showAnswer
              ? isCorrect
                  ? Colors.green.withOpacity(isDarkMode ? 0.2 : 0.1)
                  : isSelected
                      ? Colors.red.withOpacity(isDarkMode ? 0.2 : 0.1)
                      : null
              : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: index,
              groupValue: _selectedOptionIndex,
              fillColor: MaterialStateColor.resolveWith(
                  (states) => theme.colorScheme.primary),
              onChanged: !_isAnswerSubmitted
                  ? (value) => setState(() => _selectedOptionIndex = value)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: showAnswer && isCorrect
                      ? Colors.green.shade800
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        onPressed: _isLoading
            ? null
            : () async {
                if (!_isAnswerSubmitted && _selectedOptionIndex != null) {
                  _submitAnswer();
                } else if (_isAnswerSubmitted && hasNextQuestion) {
                  _goToNextQuestion();
                } else if (_isAnswerSubmitted && !hasNextQuestion) {
                  await _finishQuiz();
                }
              },
        child: _isLoading
            ? const BouncingDotsLoader(
                color: Colors.white,
                dotSize: 12,
                duration: Duration(milliseconds: 800),
              )
            : Text(
                !_isAnswerSubmitted
                    ? 'Submit Answer'
                    : hasNextQuestion
                        ? 'Next Question'
                        : 'Finish Quiz',
                style: theme.textTheme.labelLarge,
              ),
      ),
    );
  }

  Widget _buildResultSection(ThemeData theme) {
    final isCorrect = _selectedOptionIndex == currentQuiz.correctOptionIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              isCorrect ? 'Correct Answer!' : 'Incorrect Answer',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            if (currentQuiz.explanation != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  currentQuiz.explanation!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _submitAnswer() {
    _userAnswers[_currentQuestionIndex] = _selectedOptionIndex!;
    setState(() => _isAnswerSubmitted = true);
  }

  void _goToNextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedOptionIndex = null;
      _isAnswerSubmitted = false;
    });
  }

  // Add this to track answers
  final Map<int, int> _userAnswers = {};
}
