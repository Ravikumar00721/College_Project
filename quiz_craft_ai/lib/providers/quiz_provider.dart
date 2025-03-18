import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quizmodel.dart';

final quizProvider = StreamProvider<List<QuizModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('quizzes')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => QuizModel.fromDocument(doc)).toList();
  });
});

final textDataProvider = StreamProvider<List<TextDataModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('extracted_texts')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => TextDataModel.fromDocument(doc)).toList();
  });
});

final quizRepositoryProvider = Provider((ref) => QuizRepository());

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addQuiz(QuizModel quiz) async {
    await _firestore.collection('quizzes').doc(quiz.id).set(quiz.toJson());
  }

  Future<void> deleteQuiz(String id) async {
    await _firestore.collection('quizzes').doc(id).delete();
  }
}
