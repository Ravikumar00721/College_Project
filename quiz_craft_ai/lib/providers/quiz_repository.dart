import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quizmodel.dart';

final quizRepositoryProvider = Provider((ref) => QuizRepository());

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add quiz to Firestore
  Future<void> addQuiz(QuizModel quiz) async {
    await _firestore.collection('quizzes').doc(quiz.id).set(quiz.toJson());
  }

  // Delete quiz from Firestore
  Future<void> deleteQuiz(String id) async {
    await _firestore.collection('quizzes').doc(id).delete();
  }
}
