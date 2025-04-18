import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_craft_ai/models/quizmodel.dart';

class QuizResult {
  final DateTime timestamp;
  final int correctAnswers;
  final String userId;
  final int totalQuestions;
  final List<QuizModel> quizzes;
  final List<int?> userAnswers;
  final String selectedSubCategory;
  final String selectedSubject;

  QuizResult({
    required this.timestamp,
    required this.userId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.quizzes,
    required this.userAnswers,
    this.selectedSubCategory = "",
    this.selectedSubject = "",
  });

  factory QuizResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return QuizResult(
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      correctAnswers: (data['correctAnswers'] as num).toInt(),
      totalQuestions: (data['totalQuestions'] as num).toInt(),
      quizzes: (data['quizzes'] as List<dynamic>)
          .map((q) => QuizModel.fromMap(q as Map<String, dynamic>))
          .toList(),
      userAnswers: (data['userAnswers'] as List<dynamic>)
          .map((e) => e != null ? (e as num).toInt() : null)
          .toList(),
      userId: data['userId'] ?? '',
      selectedSubCategory: data['selectedSubCategory'] ?? '',
      selectedSubject: data['selectedSubject'] ?? '',
    );
  }

  int get score => (correctAnswers / totalQuestions * 100).round();
}
