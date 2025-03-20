import 'package:flutter/material.dart';

import '../../models/quizmodel.dart';

class QuizView extends StatefulWidget {
  final QuizModel quiz;

  const QuizView({Key? key, required this.quiz}) : super(key: key);

  @override
  _QuizViewState createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int? _selectedOptionIndex;
  bool _isAnswerSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionCard(),
          const SizedBox(height: 24),
          ...widget.quiz.options.asMap().entries.map((entry) {
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

  Widget _buildQuestionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          widget.quiz.question,
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
      child: const Text('Submit Answer'),
    );
  }

  Widget _buildResultSection() {
    final isCorrect = _selectedOptionIndex == widget.quiz.correctOptionIndex;
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
          if (widget.quiz.explanation != null) Text(widget.quiz.explanation!),
        ],
      ),
    );
  }

  void _submitAnswer() {
    setState(() => _isAnswerSubmitted = true);
  }
}
