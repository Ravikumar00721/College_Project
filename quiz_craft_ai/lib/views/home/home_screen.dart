import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_craft_ai/services/auth_services.dart';

import '../../core/themes.dart';
import 'create_profile.dart'; // Import Create Profile Bottom Sheet

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  User? user = FirebaseAuth.instance.currentUser;
  bool _profileExists = false; // ✅ Tracks if profile already exists
  bool _profileDialogShown = false; // Prevent multiple pop-ups

  String fullName = "Guest User"; // Default name
  String email = "user@example.com"; // Default email
  String profileImage = ""; // Default empty image

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user data from Firestore
  }

  // ✅ Fetch User Profile from Firestore
  Future<void> _fetchUserProfile() async {
    if (user != null) {
      setState(() {
        email = user!.email ?? "user@example.com"; // Update email
      });

      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(email)
            .get();

        if (doc.exists) {
          setState(() {
            fullName = doc["fullName"] ?? "Guest User";
            profileImage = doc["profileImagePath"] ?? "";
            _profileExists = true; // ✅ Profile exists
          });
        } else {
          setState(() {
            _profileExists = false; // Profile doesn't exist
          });
        }
      } catch (e) {
        print("🔥 Error fetching profile: $e");
      }

      // ✅ Show bottom sheet only if profile does NOT exist
      if (!_profileExists) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _showCreateProfileBottomSheet());
      }
    }
  }

  // ✅ Show Bottom Sheet ONLY if Profile Doesn't Exist
  Future<void> _showCreateProfileBottomSheet() async {
    if (!_profileDialogShown && !_profileExists) {
      _profileDialogShown = true; // Prevent multiple pop-ups

      bool? result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        enableDrag: false, // Prevents user from dismissing manually
        barrierColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => CreateProfileBottomSheet(),
      );

      if (result == true) {
        setState(() {
          _profileExists = true; // ✅ Mark profile as existing after submit
        });
        _fetchUserProfile(); // Reload profile after submission
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.background,
        child: Column(
          children: [
            // 🔹 Custom Drawer Header
            Container(
              height: 200,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // 🔹 Profile Image (Default if Not Available)
                  _buildProfileAvatar(),

                  SizedBox(width: 16),

                  // 🔹 Name & Email aligned to left
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🔹 Drawer Tiles
            ListTile(
              leading: Icon(Icons.person, color: AppColors.primary),
              title: Text("My Profile",
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                context.go('/myprofile');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: AppColors.primary),
              title: Text("Sign Out",
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () async {
                await authService.signOut();
                context.go("/login");
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: AppColors.background,
        child: Center(),
      ),
    );
  }

  // ✅ **Profile Avatar Widget**
  Widget _buildProfileAvatar() {
    return profileImage.isNotEmpty
        ? CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(profileImage),
          )
        : CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: SvgPicture.asset(
              'assets/image/buisness.svg',
              width: 40,
              height: 40,
            ),
          );
  }
}
