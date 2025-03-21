import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/quizmodel.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  // Reference to the text data collection
  CollectionReference get textDataCollection =>
      _firestore.collection('textData');

  /// 📌 Save extracted text to Firestore and return the document ID
  Future<String?> saveExtractedText(TextDataModel textData) async {
    try {
      if (user == null) throw Exception('User not authenticated');

      // Use .add() to create a new document with an auto-generated ID
      final docRef = await textDataCollection.add({
        'userId': user!.uid,
        'extractedText': textData.extractedText,
        'timestamp': textData.timestamp,
        'sourceType': textData.sourceType,
      });

      // Return the auto-generated document ID
      return docRef.id;
    } catch (e) {
      print('🔥 Firestore save error: $e');
      return null; // Return null if there's an error
    }
  }

  /// 📌 Get user's text history
  Stream<List<TextDataModel>> getTextHistory() {
    if (user == null) return const Stream.empty();

    return textDataCollection
        .where('userId', isEqualTo: user!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TextDataModel.fromDocument(doc))
            .toList());
  }
}
