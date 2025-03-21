import 'package:flutter/material.dart';

import '../../models/quizmodel.dart';

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionCount(),
          _buildQuestionCard(),
          const SizedBox(height: 24),
          ...currentQuiz.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return _buildOptionButton(index, option);
          }).toList(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
          if (_isAnswerSubmitted) _buildResultSection(),
        ],
      ),
    );
  }

  Widget _buildQuestionCount() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        'Question ${_currentQuestionIndex + 1} of ${widget.quizzes.length}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          currentQuiz.question,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index, String option) {
    return RadioListTile<int>(
      title: Text(option),
      value: index,
      groupValue: _selectedOptionIndex,
      onChanged: _isAnswerSubmitted
          ? null
          : (value) {
              setState(() => _selectedOptionIndex = value);
            },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _selectedOptionIndex != null ? _submitAnswer : null,
      child: Text(_isAnswerSubmitted ? 'Continue' : 'Submit Answer'),
    );
  }

  Widget _buildResultSection() {
    final isCorrect = _selectedOptionIndex == currentQuiz.correctOptionIndex;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        border: Border.all(color: isCorrect ? Colors.green : Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red),
          const SizedBox(height: 10),
          Text(
            isCorrect ? 'Correct Answer!' : 'Incorrect Answer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          if (currentQuiz.explanation != null) Text(currentQuiz.explanation!),
          const SizedBox(height: 20),
          if (hasNextQuestion)
            ElevatedButton(
              onPressed: _goToNextQuestion,
              child: const Text('Next Question'),
            )
          else
            ElevatedButton(
              onPressed: () {
                // Handle quiz completion
                Navigator.pop(context);
              },
              child: const Text('Finish Quiz'),
            ),
        ],
      ),
    );
  }

  void _submitAnswer() {
    setState(() => _isAnswerSubmitted = true);
  }

  void _goToNextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedOptionIndex = null;
      _isAnswerSubmitted = false;
    });
  }
}
