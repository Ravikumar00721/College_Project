import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_craft_ai/services/auth_services.dart';

import '../../core/themes.dart';
import '../../services/ocr_services.dart';
import 'create_profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  User? user = FirebaseAuth.instance.currentUser;
  bool _profileExists = false;
  bool _profileDialogShown = false;

  String fullName = "Guest User";
  String email = "user@example.com";
  String profileImage = "";
  File? _pickedImage;
  String? selectedFileName;
  String? extractedText;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (user != null) {
      setState(() {
        email = user!.email ?? "user@example.com";
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
            _profileExists = true;
          });
        } else {
          setState(() {
            _profileExists = false;
          });
        }
      } catch (e) {
        print("🔥 Error fetching profile: $e");
      }
      if (!_profileExists) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _showCreateProfileBottomSheet());
      }
    }
  }

  Future<void> _showCreateProfileBottomSheet() async {
    if (!_profileDialogShown && !_profileExists) {
      _profileDialogShown = true;
      bool? result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        enableDrag: false,
        barrierColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => CreateProfileBottomSheet(),
      );
      if (result == true) {
        setState(() {
          _profileExists = true;
        });
        _fetchUserProfile();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset:
          true, // Allows content to resize when the keyboard appears
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
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
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
                _buildProfileAvatar(),
                SizedBox(width: 16),
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
          ListTile(
            leading: Icon(Icons.person, color: AppColors.primary),
            title: Text("My Profile",
                style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              context.go('/myprofile');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.history,
              color: AppColors.primary,
            ),
            title: Text(
              "History",
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              context.go("");
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
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
              .onDrag, // Dismiss keyboard on scroll
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight, // Ensure it takes full height
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent,
                    Colors.purpleAccent
                  ], // Gradient Background
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100), // Add space
                  _buildAIRecommendations(),
                  SizedBox(height: 5),
                  _buildProgressIndicator(),
                  SizedBox(height: 20),
                  _buildDailyChallenge(),
                  SizedBox(height: 20),
                  _buildUploadButtons(),
                  SizedBox(height: 20),
                  _buildTextField(), // TextField now properly scrolls
                  SizedBox(height: 20),
                  _buildGenerateQuizButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAIRecommendations() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "🔥 Recommended Topic: Math",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity, // Full width inside card
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.purpleAccent
            ], // Matching `_buildAIRecommendations`
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "📌 Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 0.3), // 30% progress
              duration: Duration(seconds: 1),
              builder: (context, value, child) {
                return Stack(
                  children: [
                    Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(
                            0.3), // Transparent white for visibility
                      ),
                    ),
                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width *
                          0.8 *
                          value, // 80% of screen width
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color:
                            Colors.white, // White progress bar inside gradient
                      ),
                    ),
                    Positioned(
                      right: 8, // Aligns to the right inside the progress bar
                      top: 2,
                      child: Text(
                        "30%",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallenge() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.orangeAccent,
              Colors.redAccent
            ], // Eye-catching colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "🎯 Daily Challenge: Science Quiz",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child:
                  Text("Start", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButtons() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildUploadButton(
                    Icons.picture_as_pdf,
                    "Upload PDF",
                    () async {
                      final result = await OCRServices.pickPDFAndExtractText();
                      if (result != null) {
                        setState(() {
                          selectedFileName = result['fileName'];
                          extractedText = result['extractedText'];
                        });
                      }
                    },
                    Colors.redAccent,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildUploadButton(
                    Icons.image,
                    "Pick Image",
                    () async {
                      final result =
                          await OCRServices.pickImageAndExtractText();
                      if (result != null) {
                        setState(() {
                          selectedFileName = result['fileName'];
                          extractedText = result['extractedText'];
                        });
                      }
                    },
                    Colors.blueAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (selectedFileName != null) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Text extracted successfully!',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(
      IconData icon, String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        foregroundColor: color,
        elevation: 4,
        padding:
            EdgeInsets.symmetric(vertical: 20), // Adjust height dynamically
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          SizedBox(width: 8),
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGenerateQuizButton() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.greenAccent], // Modern gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // White button inside gradient
                  foregroundColor: Colors.greenAccent, // Text color
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 18), // Adjust height
                  elevation: 4,
                ),
                onPressed: () {},
                child: Text("Generate Quiz",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.purpleAccent,
              Colors.blueAccent
            ], // Eye-catching gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📝 Enter Text",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 8),
            Container(
              height: 160, // Set height to 200px
              decoration: BoxDecoration(
                color: Colors.white, // White background inside gradient card
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Type something...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: null, // Allows multiline input
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
