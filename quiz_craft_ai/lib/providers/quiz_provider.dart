import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quizmodel.dart';
import '../services/api_services.dart';

// Fetch Quiz from API
final quizProvider =
    FutureProvider.family<QuizModel, String>((ref, documentId) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.fetchProcessedText(documentId);
});

// Listen to Extracted Text Data from Firestore
final textDataProvider = StreamProvider<List<TextDataModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('extracted_texts')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => TextDataModel.fromDocument(doc)).toList();
  });
});
