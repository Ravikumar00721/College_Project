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

  // ✅ Fetch Profile from Firestore
  Future<void> loadUserProfile(String email) async {
    print("📥 Fetching user profile for: $email");

    ProfileModel? profile = await _authService.getUserProfile(email);
    if (profile != null) {
      print("✅ Profile loaded successfully.");
    } else {
      print("❌ Error: Profile not found for email: $email");
    }

    state = profile;
  }

  Future<void> updateProfile(ProfileModel updatedProfile) async {
    print("🔄 Updating user profile in Firestore...");

    try {
      await _authService.saveUserProfile(updatedProfile);
      state = updatedProfile; // ✅ Update Riverpod state
      print("✅ Profile updated successfully in Firestore.");
    } catch (e) {
      print("🔥 Error updating profile in Firestore: $e");
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    print("📸 Starting image upload...");

    if (!imageFile.existsSync()) {
      print("❌ Error: File does not exist at path: ${imageFile.path}");
      return null;
    }

    // ✅ Upload image and get URL
    String? imageUrl = await _storageService.uploadProfileImage(imageFile);

    if (imageUrl != null) {
      print("✅ Image uploaded successfully: $imageUrl");

      if (state == null) {
        print("⚠️ Warning: `state` is null, fetching user profile first...");
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await loadUserProfile(user.email!);
        }
      }

      if (state != null) {
        ProfileModel updatedProfile =
            state!.copyWith(profileImagePath: imageUrl);
        await updateProfile(updatedProfile);
        print("✅ Profile updated with new image URL.");

        return imageUrl; // ✅ Return the new image URL
      } else {
        print("❌ Error: Profile state is still null after fetching.");
      }
    } else {
      print("❌ Error: Image URL is null.");
    }

    return null;
  }

  // ✅ Sign Out User
  Future<void> signOut() async {
    print("🚪 Signing out user...");
    await _authService.signOut();
    state = null;
    print("✅ User signed out.");
  }
}
