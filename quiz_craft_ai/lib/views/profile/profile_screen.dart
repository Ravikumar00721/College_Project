import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quiz_craft_ai/core/themes.dart';
import 'package:quiz_craft_ai/views/profile/profile_edit_sheet.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  File? _profileImage;

  // Function to pick an image from gallery or camera
  Future<void> _pickImage() async {
    try {
      // Show options to pick image from gallery or camera
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return; // If user cancels, do nothing

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Dialog to choose between camera and gallery
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
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "My Profile",
              style: TextStyle(color: Colors.white),
            ),
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
                  builder: (context) => ProfileEditSheet(),
                );
              },
              icon: Icon(Icons.edit, color: Colors.white),
              label: Text("Edit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      body: Column(
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
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!) as ImageProvider
                        : AssetImage('assets/image/RaviKumar.jpeg'),
                    child: _profileImage == null
                        ? Icon(Icons.camera_alt,
                            color: Colors.white70, size: 24)
                        : null,
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ravi Kumar",
                        style: TextStyle(fontSize: 25, color: Colors.white)),
                    Text("BCA, SEC-A, 3rd Year",
                        style: TextStyle(fontSize: 15, color: Colors.white70)),
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
                  _buildSectionTitle("Personal Details"),
                  _buildInfoRow("Full Name", "Ravi Kumar"),
                  _buildInfoRow("Date of Birth", "22 Sep 2002"),
                  _buildInfoRow("Gender", "Male"),
                  _buildSectionTitle("Academic Information"),
                  _buildInfoRow("Education Level", "College"),
                  _buildInfoRow("Class/Year", "3rd Year BCA"),
                  _buildInfoRow("College Name", "ABC University"),
                  _buildInfoRow("Stream/Major", "Computer Science"),
                  _buildSectionTitle("Study Preferences"),
                  _buildInfoRow(
                      "Subjects of Interest", "Mathematics, Programming"),
                  _buildInfoRow("Learning Mode", "Visual & Quizzes"),
                  _buildInfoRow("Daily Study Goal", "2 Hours"),
                  _buildSectionTitle("Contact & Login Information"),
                  _buildInfoRow("Email", "ravi.kumar@example.com"),
                  _buildInfoRow("Phone Number", "+91 9876543210"),
                  _buildInfoRow("Login Method", "Google"),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Info Row Widget
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          Divider(thickness: 1, color: Colors.black26),
        ],
      ),
    );
  }
}
