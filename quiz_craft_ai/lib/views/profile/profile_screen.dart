import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quiz_craft_ai/core/themes.dart';
import 'package:quiz_craft_ai/views/profile/profile_edit_sheet.dart';

import '../../providers/user_provider.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  File? _profileImage;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String _defaultPlaceholder = 'assets/image/buisness.svg'; // Placeholder image

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // ✅ Fetch User Data from Firestore
  Future<void> _fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.email)
          .get();

      if (doc.exists) {
        setState(() {
          _userData = doc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("🔥 Error fetching profile: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        File file = File(image.path);

        setState(() {
          _isLoading = true; // Show loading indicator while uploading
        });

        // ✅ Now this correctly retrieves the new image URL
        String? newImageUrl =
            await ref.read(profileProvider.notifier).uploadProfileImage(file);

        if (newImageUrl != null) {
          print("✅ Image uploaded successfully: $newImageUrl");

          setState(() {
            _userData?['profileImagePath'] = newImageUrl;
            _profileImage = file; // Show the selected image immediately
            _isLoading = false;
          });
        } else {
          print("❌ Error: Failed to upload image.");
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("🔥 Error picking image: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ Dialog to choose between Camera and Gallery
  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Image Source"),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: Icon(Icons.camera_alt),
            label: Text("Camera"),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: Icon(Icons.photo_library),
            label: Text("Gallery"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/home'),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            "My Profile",
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  isScrollControlled: true,
                  builder: (context) => ProfileEditSheet(
                    onUpdate: _fetchUserProfile, // ✅ Refresh profile data
                  ),
                );
              },
              icon: Icon(Icons.edit, color: Colors.white),
              label: Text("Edit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator()) // 🔹 Show Loading Indicator
          : Column(
              children: [
                // 🔹 Fixed Header (Profile Section)
                Container(
                  width: double.infinity,
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickImage, // Allow user to select a new image
                        child: CircleAvatar(
                          maxRadius: 50.0,
                          backgroundColor: AppColors.background,
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.white) // Show progress
                              : (_profileImage != null)
                                  ? ClipOval(
                                      child: Image.file(
                                        _profileImage!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : (_userData?['profileImagePath'] != null &&
                                          _userData!['profileImagePath']
                                              .isNotEmpty)
                                      ? ClipOval(
                                          child: Image.network(
                                            _userData!['profileImagePath'],
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : SvgPicture.asset(
                                          _defaultPlaceholder,
                                          width: 60,
                                          height: 60,
                                        ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userData?['fullName'] ?? "Guest User",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                          Text(
                            _userData?['classYear'] ?? "Unknown Class",
                            style:
                                TextStyle(fontSize: 15, color: Colors.white70),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // 🔹 Scrollable Info Section
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        _buildSection("Personal Details", [
                          _buildInfoTile(
                              "Full Name", _userData?['fullName'] ?? "N/A"),
                          _buildInfoTile("Date of Birth",
                              _userData?['dateOfBirth'] ?? "N/A"),
                          _buildInfoTile(
                              "Gender", _userData?['gender'] ?? "N/A"),
                        ]),
                        _buildSection("Academic Information", [
                          _buildInfoTile(
                              "Class/Year", _userData?['classYear'] ?? "N/A"),
                          _buildInfoTile("College Name",
                              _userData?['collegeName'] ?? "N/A"),
                          _buildInfoTile(
                              "Stream/Major", _userData?['stream'] ?? "N/A"),
                          _buildInfoTile(
                              "Subjects", _userData?['subjects'] ?? "N/A"),
                          _buildInfoTile(
                              "Study Mode", _userData?['studyMode'] ?? "N/A"),
                          _buildInfoTile("Daily Study Goal",
                              _userData?['dailyGoal'] ?? "N/A"),
                        ]),
                        _buildSection("Contact & Login Information", [
                          _buildInfoTile("Email", _userData?['email'] ?? "N/A"),
                          _buildInfoTile("Phone Number",
                              _userData?['phoneNumber'] ?? "N/A"),
                        ]),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }
}
