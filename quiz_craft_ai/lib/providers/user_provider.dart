import 'dart:io';

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

  ProfileNotifier(this._authService, this._storageService) : super(null);

  // Updated to use UID instead of email
  Future<void> loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    print("📥 Fetching user profile for UID: ${user.uid}");

    ProfileModel? profile = await _authService.getUserById(user.uid);
    if (profile != null) {
      print("✅ Profile loaded successfully.");
    } else {
      print("❌ Error: Profile not found for UID: ${user.uid}");
    }

    state = profile;
  }

  Future<void> updateProfile(ProfileModel updatedProfile) async {
    try {
      print("🔄 Updating profile for UID: ${updatedProfile.userId}");
      await _authService.saveUserProfile(updatedProfile);
      state = updatedProfile;
      print("✅ Profile updated successfully");
    } catch (e) {
      print("🔥 Error updating profile: $e");
      throw Exception("Failed to update profile");
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ No authenticated user");
      return null;
    }

    try {
      print("📸 Starting image upload for UID: ${user.uid}");

      // 1. Upload image to storage
      final imageUrl = await _storageService.uploadProfileImage(imageFile);

      if (imageUrl == null) {
        print("❌ Failed to get image URL");
        return null;
      }

      // 2. Update profile with new image URL
      final currentProfile = state ??
          ProfileModel(
            userId: user.uid,
            email: user.email ?? "",
            fullName: user.displayName ?? "New User",
          );

      final updatedProfile =
          currentProfile.copyWith(profileImagePath: imageUrl);

      await updateProfile(updatedProfile);
      print("✅ Image updated successfully");
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
