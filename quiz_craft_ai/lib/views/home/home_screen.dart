import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_craft_ai/services/auth_services.dart';
import 'package:quiz_craft_ai/services/ocr_services.dart';

import '../../core/themes.dart';
import '../../models/quizmodel.dart';
import '../../services/textdata.dart';
import 'create_profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;
  bool _profileExists = false;
  bool _profileDialogShown = false;

  String fullName = "Guest User";
  String email = "user@example.com";
  String profileImage = "";
  bool _isHovered = false;
  String? selectedFileName;
  String? extractedText;
  late TextEditingController _textController;
  String? _selectedInputSource;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textController = TextEditingController();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    if (user != null) {
      setState(() => email = user!.email ?? "user@example.com");
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
          setState(() => _profileExists = false);
        }
      } catch (e) {
        print("Error fetching profile: $e");
      }
      if (!_profileExists && !_profileDialogShown) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _showCreateProfileBottomSheet());
      }
    }
  }

  Future<void> _showCreateProfileBottomSheet() async {
    _profileDialogShown = true;
    bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) => CreateProfileBottomSheet(),
    );
    if (result == true) {
      setState(() => _profileExists = true);
      _fetchUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QuizCraft AI',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(),
      body: _buildContent(),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _buildTextInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter Content',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800])),
        SizedBox(height: 16),
        Container(
          constraints: BoxConstraints(
            minHeight: 120, // Reduced from 150
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _textController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: 'Paste or type your content here...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (value) => setState(() {
              if (value.isNotEmpty) {
                _selectedInputSource = 'text';
              } else {
                _selectedInputSource = null;
              }
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 220,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.9),
                  AppColors.primary.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: MouseRegion(
              onHover: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: _isHovered ? 1.05 : 1.0,
                child: Row(
                  children: [
                    _buildProfileAvatar(),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            child: Text(fullName),
                          ),
                          const SizedBox(height: 8),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: 0.8,
                            child: Text(
                              email,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedList(
              padding: EdgeInsets.zero,
              initialItemCount: 4,
              itemBuilder: (context, index, animation) {
                return SlideTransition(
                  position: animation.drive(
                    Tween<Offset>(
                      begin: const Offset(-1, 0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeOut)),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: _buildDrawerItem(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index) {
    switch (index) {
      case 0:
        return _drawerItem(
            Icons.account_circle_outlined, 'My Profile', '/myprofile');
      case 1:
        return _drawerItem(
            Icons.history_toggle_off_outlined, 'History', '/history');
      case 2:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: Colors.grey[300], height: 1),
        );
      case 3:
        return _drawerItem(
          Icons.logout_outlined,
          'Sign Out',
          '/login',
          isSignOut: true,
          color: Colors.redAccent,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _drawerItem(IconData icon, String title, String route,
      {bool isSignOut = false, Color? color}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (isSignOut) await authService.signOut();
          context.go(route);
        },
        hoverColor: Colors.grey[100],
        splashColor: AppColors.primary.withOpacity(0.1),
        child: ListTile(
          leading: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(icon, color: color ?? AppColors.primary, size: 28),
          ),
          title: Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isSignOut ? Colors.redAccent : Colors.grey[800])),
          trailing: Icon(Icons.chevron_right_rounded,
              color: color ?? AppColors.primary.withOpacity(0.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                physics: isKeyboardOpen
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUploadSection(),
                              SizedBox(height: 24),
                              _buildTextInputSection(),
                              SizedBox(height: 24),
                              _buildInputSourceMessage(),
                            ],
                          ),
                        ),
                      ),
                      // Keyboard spacer
                      SizedBox(height: isKeyboardOpen ? 80 : 0),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomActionBar(),
          ],
        );
      },
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Content',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800])),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildUploadButton(
                    Icons.picture_as_pdf_outlined, "PDF File", Colors.red, () {
              _handleFileUpload('pdf');
            })),
            SizedBox(width: 16),
            Expanded(
                child: _buildUploadButton(
                    Icons.image_outlined, "Image", Colors.blue, () {
              _handleFileUpload('image');
            })),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadButton(
      IconData icon, String label, Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildInputSourceMessage() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      child: _selectedInputSource != null
          ? Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  _selectedInputSource == 'text'
                      ? 'Using manual input'
                      : 'Selected ${_selectedInputSource!.toUpperCase()} file',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            )
          : SizedBox.shrink(),
    );
  }

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 32,
      backgroundColor: Colors.white24,
      child: profileImage.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.network(profileImage, fit: BoxFit.cover))
          : Icon(Icons.person_outline, size: 32, color: Colors.white),
    );
  }

  Future<void> _handleFileUpload(String type) async {
    final result = type == 'pdf'
        ? await OCRServices.pickPDFAndExtractText()
        : await OCRServices.pickImageAndExtractText(context);

    if (result != null) {
      setState(() {
        _selectedInputSource = type;
        _textController.text = result['extractedText']!;
      });
    }
  }

  Future<void> _handleGeneratePress() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please input some text')));
      return;
    }

    final textData = TextDataModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user?.uid ?? '',
      extractedText: _textController.text,
      timestamp: DateTime.now(),
      sourceType: _selectedInputSource ?? 'text',
    );

    final documentId = await firestoreService.saveExtractedText(textData);

    if (documentId != null) {
      context.push('/generate-quiz/$documentId');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save text data')));
    }
  }

  Widget _buildBottomActionBar() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 100),
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _handleGeneratePress,
                child: Text('Generate Quiz Questions',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _textController.clear();
      setState(() => _selectedInputSource = null);
    }
  }
}
