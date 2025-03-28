import 'package:flutter/material.dart';
import 'package:quiz_craft_ai/views/quiz/result_screen.dart';

import '../../models/quizmodel.dart';
import '../../services/auth_services.dart';

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

  QuizModel get currentQuiz => widget.quizzes[_currentQuestionIndex];
  bool get hasNextQuestion => _currentQuestionIndex < widget.quizzes.length - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionCount(),
            _buildQuestionCard(),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: currentQuiz.options.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _buildOptionButton(index),
              ),
            ),
            const SizedBox(height: 16),
            _buildControlButton(),
            if (_isAnswerSubmitted) _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCount() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        'Question ${_currentQuestionIndex + 1} of ${widget.quizzes.length}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          currentQuiz.question,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index) {
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
                  ? Colors.green.shade100
                  : isSelected
                      ? Colors.red.shade100
                      : null
              : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: index,
              groupValue: _selectedOptionIndex,
              onChanged: !_isAnswerSubmitted
                  ? (value) => setState(() => _selectedOptionIndex = value)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  color: showAnswer && isCorrect ? Colors.green.shade800 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          if (!_isAnswerSubmitted && _selectedOptionIndex != null) {
            _submitAnswer();
          } else if (_isAnswerSubmitted && hasNextQuestion) {
            _goToNextQuestion();
          } else if (_isAnswerSubmitted && !hasNextQuestion) {
            _finishQuiz();
          }
        },
        child: Text(
          !_isAnswerSubmitted
              ? 'Submit Answer'
              : hasNextQuestion
                  ? 'Next Question'
                  : 'Finish Quiz',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
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

  void _finishQuiz() {
    final correctAnswers = widget.quizzes
        .where((quiz) =>
            _userAnswers[widget.quizzes.indexOf(quiz)] ==
            quiz.correctOptionIndex)
        .length;

    // Save results to Firestore
    AuthService().saveQuizResult(
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
  }
}
