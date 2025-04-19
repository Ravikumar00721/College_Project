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

import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bouncing.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  File? _profileImage;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String _defaultPlaceholder = 'assets/image/buisness.svg';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid) // Changed from user.email
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
      print("Error fetching profile: $e");
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
          _isLoading = true;
        });

        String? newImageUrl =
            await ref.read(profileProvider.notifier).uploadProfileImage(file);

        if (newImageUrl != null) {
          setState(() {
            _userData?['profileImagePath'] = newImageUrl;
            _profileImage = file;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Image Source",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
        backgroundColor: Theme.of(context).cardColor,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor),
            label: Text("Camera",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: Icon(Icons.photo_library,
                color: Theme.of(context).primaryColor),
            label: Text("Gallery",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

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
          title: Text("My Profile", style: TextStyle(color: Colors.white)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                color: Colors.white,
              ),
              onPressed: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  isScrollControlled: true,
                  builder: (context) => ProfileEditSheet(
                    onUpdate: _fetchUserProfile,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: BouncingDotsLoader(
              color: AppColors.primary,
              dotSize: 20,
              duration: Duration(milliseconds: 800),
            ))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40)),
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
                        onTap: _pickImage,
                        child: CircleAvatar(
                          maxRadius: 50.0,
                          backgroundColor: isDarkMode
                              ? Colors.grey[800]
                              : AppColors.background,
                          child: _isLoading
                              ? const Center(
                                  child: BouncingDotsLoader(
                                  color: AppColors.primary,
                                  dotSize: 20,
                                  duration: Duration(milliseconds: 800),
                                ))
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
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_userData?['fullName'] ?? "Guest User",
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white)),
                          Text(_userData?['classYear'] ?? "Unknown Class",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.white70)),
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        _buildSection(context, "Academic Information", [
                          // Add this new line for category
                          _buildInfoTile(
                              context,
                              "Category",
                              _userData?['selectedCategory']?.isNotEmpty == true
                                  ? _userData!['selectedCategory']
                                  : "N/A"),
                          _buildInfoTile(context, "Class/Year",
                              _userData?['classYear'] ?? "N/A"),
                          _buildInfoTile(context, "College Name",
                              _userData?['collegeName'] ?? "N/A"),
                          _buildInfoTile(context, "Stream/Major",
                              _userData?['stream'] ?? "N/A"),
                          _buildInfoTile(context, "Subjects",
                              _userData?['subjects'] ?? "N/A"),
                          _buildInfoTile(context, "Study Mode",
                              _userData?['studyMode'] ?? "N/A"),
                          _buildInfoTile(context, "Daily Study Goal",
                              _userData?['dailyGoal'] ?? "N/A"),
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

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(color: theme.dividerColor),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          Text(value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              )),
        ],
      ),
    );
  }
}
