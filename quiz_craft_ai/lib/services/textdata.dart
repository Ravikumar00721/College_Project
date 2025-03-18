import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/quizmodel.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  // Reference to the text data collection
  CollectionReference get textDataCollection =>
      _firestore.collection('textData');

  /// 📌 Save extracted text to Firestore
  Future<void> saveExtractedText(TextDataModel textData) async {
    try {
      if (user == null) throw Exception('User not authenticated');

      await textDataCollection.doc(textData.id).set({
        'userId': user!.uid,
        'extractedText': textData.extractedText,
        'timestamp': textData.timestamp,
      });
    } catch (e) {
      print('🔥 Firestore save error: $e');
      rethrow;
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
