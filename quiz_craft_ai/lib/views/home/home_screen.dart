import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_craft_ai/services/auth_services.dart';

import '../../core/themes.dart';
import '../../models/quizmodel.dart';
import '../../services/ocr_services.dart';
import '../../services/textdata.dart';
import 'create_profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
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
  // Add in HomeScreen state
  late TextEditingController _textController;
  String? _selectedInputSource; // 'image', 'pdf', or 'text'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textController = TextEditingController();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Clear inputs when the app resumes
      _clearInputs();
    }
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
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  _buildUploadButtons(),
                  SizedBox(height: 20),
                  _buildTextField(),
                  _buildInputSourceMessage(),
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

  Widget _buildInputSourceMessage() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: _selectedInputSource != null
          ? Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    _selectedInputSource == 'text'
                        ? 'Using manual input'
                        : 'Using ${_selectedInputSource!.toUpperCase()} file${selectedFileName != null ? ': $selectedFileName' : ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          : SizedBox.shrink(),
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
                          _selectedInputSource = 'pdf';
                          _textController.text = result['extractedText']!;
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
                          await OCRServices.pickImageAndExtractText(context);
                      if (result != null) {
                        setState(() {
                          _selectedInputSource = 'image';
                          _textController.text = result['extractedText']!;
                        });
                      }
                    },
                    Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _clearInputs() {
    setState(() {
      _selectedInputSource = null;
      selectedFileName = null;
      _textController.clear();
    });
  }

// Use this when switching between input methods

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
                onPressed: () async {
                  if (_textController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please input some text')),
                    );
                    return;
                  }
                  // Save to Firebase
                  final textData = TextDataModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: user?.uid ?? '',
                    extractedText: _textController.text,
                    timestamp: DateTime.now(),
                    sourceType: _selectedInputSource ?? 'text',
                  );

                  await FirestoreService().saveExtractedText(textData);

                  // Navigate to quiz generation screen
                  context.push('/generate-quiz');
                },
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
            colors: [Colors.purpleAccent, Colors.blueAccent],
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
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: "Type or paste your content here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(12),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() => _selectedInputSource = 'text');
                  } else {
                    setState(() => _selectedInputSource = null);
                  }
                },
                maxLines: null,
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
