import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/usermodel.dart';
import '../services/auth_services.dart';
import '../services/storage_services.dart';

// 🔹 Provide AuthService instance
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 🔹 Provide StorageService instance
final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

// 🔹 Profile State Provider using AuthService
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileModel?>((ref) {
  return ProfileNotifier(
    ref.read(authServiceProvider),
    ref.read(storageServiceProvider),
  );
});

class ProfileNotifier extends StateNotifier<ProfileModel?> {
  final AuthService _authService;
  final StorageService _storageService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileNotifier(this._authService, this._storageService) : super(null);

  Future<void> loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    ProfileModel? profile = await _authService.getUserById(user.uid);

    if (profile == null) {
      // Create a complete profile if none exists
      profile = ProfileModel(
        userId: user.uid,
        email: user.email ?? "",
        fullName: user.displayName ?? "New User",
        // Add other default values here
        dateOfBirth: "",
        gender: "",
        collegeName: "",
        classYear: "",
        stream: "",
        phoneNumber: "",
        profileImagePath: "",
        selectedCategory: "",
      );
    }

    state = profile;
  }

  Future<void> updateProfile(ProfileModel profile) async {
    try {
      print('[DEBUG] Writing to Firestore: ${profile.toMap()}');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(profile.userId)
          .set(profile.toMap());
      print('[DEBUG] Firestore write complete');
    } catch (e) {
      print('[ERROR] Firestore write failed: $e');
      throw e;
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      // 1. Upload image to storage
      final imageUrl = await _storageService.uploadProfileImage(imageFile);
      if (imageUrl == null) return null;

      // 2. Update ONLY the profile image field in Firestore
      await _authService.updateProfileField(
        userId: user.uid,
        field: 'profileImagePath',
        value: imageUrl,
      );

      // 3. Update local state
      state = state?.copyWith(profileImagePath: imageUrl);
      return imageUrl;
    } catch (e) {
      print("🔥 Error uploading image: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      print("🚪 Signing out user");
      await _authService.signOut();
      state = null;
      print("✅ Sign out successful");
    } catch (e) {
      print("🔥 Error signing out: $e");
      throw Exception("Sign out failed");
    }
  }
}
