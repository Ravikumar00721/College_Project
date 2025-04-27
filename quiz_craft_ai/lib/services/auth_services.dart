import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/quiz_result.dart';
import '../models/quizmodel.dart';
import '../models/usermodel.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Sign in with Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error signing in with email: $e");
      return null;
    }
  }

  // 🔹 Register a New User (Sign Up with Email & Password)
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error signing up: $e");
      return null;
    }
  }

  // 🔹 Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) return null; // User canceled sign-in

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // 🔹 Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut(); // Sign out from Google as well
  }

  // 🔹 Password Reset (Forgot Password)
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent");
    } catch (e) {
      print("Error sending password reset email: $e");
    }
  }

  // 🔹 Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // 🔹 Apple Sign-In
  Future<User?> signInWithApple() async {
    try {
      // Request Apple ID Credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth Credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);
      return userCredential.user;
    } catch (e) {
      print("Apple Sign-In Error: $e");
      return null;
    }
  }

  Future<void> saveUserProfile(ProfileModel profile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Use Firebase UID as document ID and set userId field
      await _firestore.collection("users").doc(user.uid).set({
        ...profile.toMap(),
        "userId": user.uid, // Add UID to document data
      }, SetOptions(merge: true));

      print("✅ User profile saved successfully in Firestore.");
    } catch (e) {
      print("🔥 Error saving profile: $e");
    }
  }

  // In AuthService
  Future<void> updateProfileField({
    required String userId,
    required String field,
    required dynamic value,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        field: value,
      });
    } catch (e) {
      print("Error updating $field: $e");
      throw Exception("Field update failed");
    }
  }

  Future<ProfileModel?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot doc =
        await _firestore.collection("users").doc(user.uid).get();
    return doc.exists
        ? ProfileModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)
        : null;
  }

  Future<void> saveQuizResult({
    required List<QuizModel> quizzes,
    required int correctAnswers,
    required List<int?> userAnswers,
    required String selectedSubCategory,
    required String selectedSubject,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final totalQuestions = quizzes.length;
      final score = (correctAnswers / totalQuestions * 100).round();

      await _firestore.collection('quizResults').add({
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'score': score,
        'quizzes': quizzes.map((q) => q.toMap()).toList(),
        'userAnswers': userAnswers,
        'selectedSubCategory': selectedSubCategory,
        'selectedSubject': selectedSubject,
      });
      print("Quiz results saved successfully");
    } catch (e) {
      print("Error saving quiz results: $e");
    }
  }

  // Add to AuthService class
  Future<List<QuizResult>> getAllQuizResults() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('quizResults').get();
      return querySnapshot.docs
          .map((doc) => QuizResult.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching quiz results: $e");
      return [];
    }
  }

  Future<ProfileModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();

      return doc.exists
          ? ProfileModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>) // Add doc.id
          : null;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  // In AuthService
  Future<List<QuizResult>> getQuizResults() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('quizResults')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return QuizResult.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print("Error fetching quiz results: $e");
      return [];
    }
  }
}
