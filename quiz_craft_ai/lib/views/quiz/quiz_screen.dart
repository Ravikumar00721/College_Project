import 'package:flutter/material.dart';

import '../../models/quizmodel.dart';

class QuizScreen extends StatefulWidget {
  final QuizModel quiz; // Pass the quiz data to the screen

  const QuizScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedOptionIndex; // Track the selected option
  bool _isAnswerSubmitted = false; // Track if the answer is submitted

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Text(
              widget.quiz.question,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // Options
            ...widget.quiz.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return _buildOptionButton(index, option);
            }).toList(),

            SizedBox(height: 20),

            // Submit Button
            if (!_isAnswerSubmitted)
              ElevatedButton(
                onPressed: _selectedOptionIndex != null ? _submitAnswer : null,
                child: Text('Submit'),
              ),

            // Feedback
            if (_isAnswerSubmitted) ...[
              Text(
                _selectedOptionIndex == widget.quiz.correctOptionIndex
                    ? '✅ Correct!'
                    : '❌ Incorrect!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _selectedOptionIndex == widget.quiz.correctOptionIndex
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              if (widget.quiz.explanation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Explanation: ${widget.quiz.explanation}',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // Build an option button
  Widget _buildOptionButton(int index, String option) {
    final isCorrect = index == widget.quiz.correctOptionIndex;
    final isSelected = index == _selectedOptionIndex;

    Color? buttonColor;
    if (_isAnswerSubmitted) {
      if (isCorrect) {
        buttonColor = Colors.green; // Correct answer
      } else if (isSelected) {
        buttonColor = Colors.red; // Incorrect selected answer
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: _isAnswerSubmitted ? null : () => _selectOption(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          minimumSize: Size(double.infinity, 50),
        ),
        child: Text(
          option,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // Handle option selection
  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  // Handle answer submission
  void _submitAnswer() {
    setState(() {
      _isAnswerSubmitted = true;
    });
  }
}
