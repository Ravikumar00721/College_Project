import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;

  QuizModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });

  // Convert QuizModel to JSON for Firebase storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
    };
  }

  // Create QuizModel from Firebase document snapshot
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndex: json['correctOptionIndex'] ?? 0,
      explanation: json['explanation'],
    );
  }

  // Convert Firebase document snapshot to QuizModel
  factory QuizModel.fromDocument(DocumentSnapshot doc) {
    return QuizModel.fromJson(doc.data() as Map<String, dynamic>);
  }
}

class TextDataModel {
  final String id;
  final String userId;
  final String extractedText;
  final DateTime timestamp;

  TextDataModel({
    required this.id,
    required this.userId,
    required this.extractedText,
    required this.timestamp,
  });

  // Add this factory constructor
  factory TextDataModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TextDataModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      extractedText: data['extractedText'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Existing toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'extractedText': extractedText,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
