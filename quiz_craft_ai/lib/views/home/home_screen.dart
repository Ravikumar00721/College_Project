import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_craft_ai/services/auth_services.dart';
import 'package:quiz_craft_ai/services/ocr_services.dart';

import '../../core/themes.dart';
import '../../models/quizmodel.dart';
import '../../providers/theme_provider.dart';
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
  final Map<String, dynamic> filterOptions = {
    'School': {
      'Class 1': ['English', 'Mathematics', 'Environmental Studies (EVS)'],
      'Class 2': ['English', 'Mathematics', 'Environmental Studies (EVS)'],
      'Class 3': ['English', 'Mathematics', 'Science', 'Social Studies'],
      'Class 4': ['English', 'Mathematics', 'Science', 'Social Studies'],
      'Class 5': ['English', 'Mathematics', 'Science', 'Social Studies'],
      'Class 6': [
        'English',
        'Mathematics',
        'Science',
        'Social Studies',
        'Computer Science'
      ],
      'Class 7': [
        'English',
        'Mathematics',
        'Science',
        'Social Studies',
        'Computer Science'
      ],
      'Class 8': [
        'English',
        'Mathematics',
        'Science',
        'Social Studies',
        'Computer Science'
      ],
      'Class 9': [
        'English',
        'Mathematics',
        'Physics',
        'Chemistry',
        'Biology',
        'History',
        'Geography',
        'Civics',
        'Economics',
        'Computer Science'
      ],
      'Class 10': [
        'English',
        'Mathematics',
        'Physics',
        'Chemistry',
        'Biology',
        'History',
        'Geography',
        'Civics',
        'Economics',
        'Computer Science'
      ],
      'Class 11-12': {
        'Science Stream': [
          'Physics',
          'Chemistry',
          'Mathematics',
          'Biology',
          'Computer Science'
        ],
        'Commerce Stream': [
          'Accountancy',
          'Economics',
          'Business Studies',
          'Mathematics'
        ],
        'Arts Stream': [
          'History',
          'Political Science',
          'Geography',
          'Psychology',
          'Sociology',
          'Journalism'
        ]
      }
    },
    'College': {
      'Undergraduate Programs': {
        'BCA': [
          'Programming',
          'Database',
          'Web Development',
          'Software Engineering'
        ],
        'B.Tech': [
          'Computer Science',
          'Mechanical Engineering',
          'Civil Engineering',
          'Electrical Engineering',
          'Electronics',
          'AI & ML',
          'Data Science'
        ],
        'B.Sc': [
          'Physics',
          'Chemistry',
          'Mathematics',
          'Biology',
          'Biotechnology'
        ],
        'B.Com': ['Accountancy', 'Economics', 'Business Studies', 'Finance'],
        'BA': [
          'History',
          'Political Science',
          'Geography',
          'Psychology',
          'Journalism'
        ],
        'BBA': ['Marketing', 'Finance', 'Human Resources', 'Entrepreneurship'],
        'LLB': ['Contract Law', 'Criminal Law', 'Corporate Law'],
        'Other': ['Liberal Arts', 'Mass Communication', 'Design']
      },
      'Postgraduate Programs': {
        'MCA': [
          'Advanced Programming',
          'Cloud Computing',
          'Big Data',
          'Cyber Security'
        ],
        'M.Tech': [
          'AI & ML',
          'Embedded Systems',
          'Cybersecurity',
          'VLSI Design'
        ],
        'M.Sc': [
          'Physics',
          'Chemistry',
          'Mathematics',
          'Biotechnology',
          'Data Science'
        ],
        'M.Com': ['Advanced Accountancy', 'Financial Management', 'Taxation'],
        'MA': [
          'History',
          'Political Science',
          'Public Administration',
          'International Relations',
          'English Literature'
        ],
        'MBA': [
          'Marketing Management',
          'Financial Management',
          'Operations Management',
          'Business Analytics',
          'HR Management'
        ],
        'LLM': ['International Law', 'Constitutional Law', 'Corporate Law'],
        'Other': ['Liberal Arts', 'Public Policy', 'Mass Communication']
      }
    }
  };

  String fullName = "Guest User";
  String email = "user@example.com";
  String profileImage = "";
  bool _isHovered = false;
  String? selectedFileName;
  String? extractedText;
  late TextEditingController _textController;
  String? _selectedInputSource;

  // Add these state variables
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedSubject;
  List<String> subCategoryOptions = [];
  List<String> subjectOptions = [];
  bool _showBlockingOverlay = true;

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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => email = user.email ?? "user@example.com");
      try {
        // Use UID instead of email
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid) // Changed to user.uid
            .get();

        if (doc.exists) {
          final profileData = doc.data() as Map<String, dynamic>;
          setState(() {
            _profileExists = true;
            fullName = profileData['fullName']?.toString() ?? "Guest User";
            profileImage = profileData['profileImagePath']?.toString() ?? "";
            selectedCategory =
                profileData['selectedCategory']?.toString() ?? '';

            if (selectedCategory!.isNotEmpty) {
              subCategoryOptions = _getSubCategories(selectedCategory!);
            }
            _showBlockingOverlay = false;
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCreateProfileBottomSheet().then((_) {
              setState(() => _showBlockingOverlay = false);
            });
          });
        }
      } catch (e) {
        setState(() => _showBlockingOverlay = false);
        print("Error fetching profile: $e");
      }

      // Add null check for user.uid
      if (!_profileExists && !_profileDialogShown && user.uid.isNotEmpty) {
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
      isDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: CreateProfileBottomSheet(),
      ),
    );

    setState(() => _showBlockingOverlay = false);
    if (result == true) {
      setState(() => _profileExists = true);
      _fetchUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(themeProvider);
        final isDarkMode = ref.watch(themeProvider.notifier).isDarkMode;

        return Stack(
          children: [
            // Main Content
            _buildMainContent(ref, themeMode, isDarkMode),

            // Blocking Overlay
            if (_showBlockingOverlay)
              ModalBarrier(
                color: Colors.black.withOpacity(0.3),
                dismissible: false,
              ),

            // Progress Indicator
            if (_showBlockingOverlay)
              Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent(
      WidgetRef ref, ThemeMode themeMode, bool isDarkMode) {
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
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Icon(
                isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                key: ValueKey<bool>(isDarkMode),
                color: Colors.white,
              ),
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24).copyWith(bottom: 100),
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 100,
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
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCategorySection(),
                              const SizedBox(height: 10),
                              _buildUploadSection(),
                              const SizedBox(height: 10),
                              _buildTextInputSection(),
                              const SizedBox(height: 10),
                              _buildInputSourceMessage(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomActionBar(),
              ),
            ],
          );
        },
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  List<String> _getSubCategories(String category) {
    final categoryData = filterOptions[category];
    if (categoryData is Map<String, dynamic>) {
      return categoryData.keys.toList().cast<String>();
    }
    return [];
  }

  List<String> _getSubjects(String category, String subCategory) {
    final categoryData = filterOptions[category];
    final subCategoryData = categoryData[subCategory];

    if (subCategoryData is Map<String, dynamic>) {
      // For college programs with nested structure
      return subCategoryData.values
          .expand((subList) => (subList as List<dynamic>).cast<String>())
          .toList();
    } else if (subCategoryData is List<dynamic>) {
      return subCategoryData.cast<String>();
    }
    return [];
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Header with animations
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
              initialItemCount:
                  5, // Reduced count since we removed theme toggle
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
          Icons.account_circle_outlined,
          'My Profile',
          '/myprofile',
        );
      case 1:
        return _drawerItem(
          Icons.history_toggle_off_outlined,
          'History',
          '/history',
        );
      case 2:
        return _drawerItem(
          Icons.leaderboard_outlined, // Changed icon to leaderboard
          'Leaderboard',
          '/leaderboard',
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: Colors.grey[300], height: 1),
        );
      case 4:
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
            child: Icon(
              icon,
              color: color ?? AppColors.primary,
              size: 28,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isSignOut ? Colors.redAccent : Colors.grey[800],
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: color ?? AppColors.primary.withOpacity(0.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        ),
      ),
    );
  }

  final ScrollController _textScrollController = ScrollController();

  Widget _buildTextInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Content',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 230,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              controller: _textScrollController,
              child: TextField(
                controller: _textController,
                scrollController: _textScrollController,
                expands: true,
                maxLines: null,
                minLines: null,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Paste or type your content here...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                onChanged: (value) => setState(() {
                  _selectedInputSource = value.isNotEmpty ? 'text' : null;
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24).copyWith(bottom: 100),
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 100,
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
                        padding: const EdgeInsets.all(24),
                        child: LayoutBuilder(
                          builder: (context, cardConstraints) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCategorySection(),
                                const SizedBox(height: 10),
                                _buildUploadSection(),
                                const SizedBox(height: 10),
                                _buildTextInputSection(),
                                const SizedBox(height: 10),
                                _buildInputSourceMessage(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomActionBar(),
            ),
          ],
        );
      },
    );
  }

  // 2. Update the category section display
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subject Category',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800])),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (selectedCategory != null && selectedCategory!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text('Education Level: $selectedCategory',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700])),
                ),
              _buildCategoryDropdowns(),
              SizedBox(height: 12),
              Text(
                  'Selected: ${selectedCategory ?? 'None'} → '
                  '${selectedSubCategory ?? 'None'} → '
                  '${selectedSubject ?? 'None'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

// 3. Simplified dropdown builder
  Widget _buildCategoryDropdowns() {
    return Column(
      children: [
        if (selectedCategory != null && selectedCategory!.isNotEmpty) ...[
          _buildStyledDropdown(
            value: selectedSubCategory,
            label: _getSubCategoryLabel(),
            items: subCategoryOptions,
            onChanged: (newValue) {
              setState(() {
                selectedSubCategory = newValue;
                selectedSubject = null;
                subjectOptions = _getSubjects(selectedCategory!, newValue!);
              });
            },
          ),
          SizedBox(height: 12),
          if (selectedSubCategory != null)
            _buildStyledDropdown(
              value: selectedSubject,
              label: 'Select Subject',
              items: subjectOptions,
              onChanged: (newValue) =>
                  setState(() => selectedSubject = newValue),
            ),
        ],
      ],
    );
  }

// 4. Update helper method
  String _getSubCategoryLabel() {
    if (selectedCategory == 'School') return 'Select Class';
    if (selectedCategory == 'College') return 'Select Program';
    return 'Select Subcategory';
  }

  Widget _buildStyledDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800])),
            );
          }).toList(),
          onChanged: onChanged,
          hint: Text('Choose...', style: TextStyle(color: Colors.grey[500])),
        ),
      ),
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
    // Add category validation
    if (selectedSubCategory == null || selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select category and subject')),
      );
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
      context.push(
        '/generate-quiz/$documentId',
        extra: {
          'selectedSubCategory': selectedSubCategory!,
          'selectedSubject': selectedSubject!,
        },
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save text data')));
    }
  }

  Widget _buildBottomActionBar() {
    return Consumer(
      builder: (context, ref, _) {
        final isDarkMode = ref.watch(themeProvider.notifier).isDarkMode;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            // Remove background color to make it transparent
            color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome_outlined, size: 24),
                label: const Text(
                  'Generate Quiz Questions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
                onPressed: _handleGeneratePress,
              ),
            ),
          ),
        );
      },
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
