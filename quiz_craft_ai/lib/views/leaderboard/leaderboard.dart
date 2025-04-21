import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/leader_board_model.dart';
import '../../models/quiz_result.dart';
import '../../models/usermodel.dart';
import '../../services/auth_services.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardUser> users = [];
  bool isLoading = true;
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedSubject;
  List<String> subjectOptions = [];
  String? selectedProgram;

  @override
  void initState() {
    super.initState();
    _loadLeaderboardData();
  }

  Future<void> _loadLeaderboardData() async {
    print('[DEBUG] Loading leaderboard data...');
    final authService = AuthService();

    List<QuizResult> allResults = await authService.getAllQuizResults();
    print('[DEBUG] Total quiz results fetched: ${allResults.length}');

    Map<String, List<QuizResult>> groupedResults = {};

    for (var result in allResults) {
      print('[DEBUG] Processing result for user: ${result.userId}');
      print(
          '[DEBUG] Result details: subCategory=${result.selectedSubCategory}, subject=${result.selectedSubject}, score=${result.score}');

      String category =
          result.selectedSubCategory.startsWith('Class') ? 'School' : 'College';
      String sanitizedSubCategory =
          result.selectedSubCategory.replaceAll('_', '-');
      String sanitizedSubject = result.selectedSubject.replaceAll('_', '-');

      String key =
          '${result.userId}_${category}_${sanitizedSubCategory}_${sanitizedSubject}';

      if (!groupedResults.containsKey(key)) {
        print('[DEBUG] Creating new key group: $key');
      }

      groupedResults.putIfAbsent(key, () => []).add(result);
    }

    print('[DEBUG] Total grouped entries: ${groupedResults.length}');

    List<LeaderboardUser> leaderboardUsers = [];

    for (var entry in groupedResults.entries) {
      print(
          '[DEBUG] Processing group key: ${entry.key} with ${entry.value.length} result(s)');
      List<String> keyParts = entry.key.split('_');
      if (keyParts.length < 4) {
        print('[WARNING] Skipping invalid key: ${entry.key}');
        continue;
      }

      String userId = keyParts[0];
      String category = keyParts[1];
      String subCategory = keyParts[2].replaceAll('-', '_');
      String subject = keyParts.sublist(3).join('_').replaceAll('-', '_');

      double totalScore =
          entry.value.fold(0, (sum, result) => sum + result.score);
      int averageScore = (totalScore / entry.value.length).round();

      print('[DEBUG] Fetching profile for userId: $userId');
      ProfileModel? profile = await authService.getUserById(userId);
      if (profile == null) {
        print('[WARNING] No profile found for userId: $userId. Skipping...');
        continue;
      }

      print(
          '[DEBUG] Profile fetched: ${profile.fullName}, Score: $averageScore');

      leaderboardUsers.add(LeaderboardUser(
        rank: 0,
        userId: userId,
        name: profile.fullName,
        score: averageScore,
        imageUrl: profile.profileImagePath,
        category: category,
        subCategory: subCategory,
        subject: subject,
      ));
    }

    leaderboardUsers.sort((a, b) => b.score.compareTo(a.score));

    for (int i = 0; i < leaderboardUsers.length; i++) {
      leaderboardUsers[i] = leaderboardUsers[i].copyWith(rank: i + 1);
    }

    // Final print to verify results
    print('=== LEADERBOARD CALCULATION RESULTS ===');
    print('Total Users: ${leaderboardUsers.length}');
    print('---------------------------------------');
    leaderboardUsers.forEach((user) {
      print('Rank ${user.rank.toString().padLeft(3)} | '
          'Score: ${user.score.toString().padLeft(3)}% | '
          'Category: ${user.category.padRight(8)} | '
          'Sub: ${user.subCategory.padRight(18)} | '
          'Subject: ${user.subject.padRight(20)} | '
          'Name: ${user.name}');
    });
    print('=======================================');

    setState(() {
      users = leaderboardUsers;
      isLoading = false;
    });
  }

  List<LeaderboardUser> get filteredUsers {
    return users.where((user) {
      if (selectedCategory != null && user.category != selectedCategory)
        return false;

      if (selectedSubCategory != null) {
        if (user.category == 'School') {
          if (user.subCategory != selectedSubCategory) return false;
        } else {
          // For college, check if subject exists in selected subcategory's subjects
          if (!subjectOptions.contains(user.subject)) return false;
        }
      }

      if (selectedSubject != null && user.subject != selectedSubject)
        return false;

      return true;
    }).toList();
  }

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
      'Class 11-12': {'Science Stream', 'Commerce Stream', 'Arts Stream'}
    },
    'College': {
      'Undergraduate Programs': [
        'Programming', 'Database', 'Web Development', 'Software Engineering',
        'Computer Science', 'Mechanical Engineering', 'Civil Engineering',
        // ... rest of UG subjects
      ],
      'Postgraduate Programs': [
        'Advanced Programming', 'Cloud Computing', 'Big Data', 'Cyber Security',
        'AI & ML', 'Embedded Systems', 'Cybersecurity', 'VLSI Design',
        // ... rest of PG subjects
      ]
    }
  };

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    final displayedUsers = filteredUsers;
    final top3 = displayedUsers.take(3).toList();
    final remainingUsers = displayedUsers.skip(3).toList();

    List<String> getSubjectsForSubCategory(String subCategory) {
      if (selectedCategory == 'School') {
        return (filterOptions['School'][subCategory] as List?)
                ?.cast<String>() ??
            [];
      } else {
        // Directly return subjects for college programs
        return (filterOptions['College'][subCategory] as List?)
                ?.cast<String>() ??
            [];
      }
    }

    Widget _buildSubCategoryDropdown() {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      List<String> subCategories = [];
      if (selectedCategory == 'School') {
        subCategories =
            (filterOptions['School'] as Map).keys.toList().cast<String>();
      } else if (selectedCategory == 'College') {
        subCategories =
            (filterOptions['College'] as Map).keys.toList().cast<String>();
      }

      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            selectedCategory == 'School'
                ? 'Select Class'
                : 'Select Program Type',
            style:
                TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
          ),
          value: selectedSubCategory,
          items: subCategories.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedSubCategory = value;
              selectedSubject = null;
              subjectOptions = getSubjectsForSubCategory(value!);
            });
          },
          icon: Icon(Icons.arrow_drop_down,
              color: isDarkMode ? Colors.white70 : Colors.grey),
          isExpanded: true,
          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
        ),
      );
    }

    Widget _buildSubjectDropdown() {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            'Select Subject',
            style:
                TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
          ),
          value: selectedSubject,
          items: subjectOptions.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedSubject = value),
          icon: Icon(Icons.arrow_drop_down,
              color: isDarkMode ? Colors.white70 : Colors.grey),
          isExpanded: true,
          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
        ),
      );
    }

    Widget _buildCategoryDropdown() {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            'Select Category',
            style:
                TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
          ),
          value: selectedCategory,
          items: ['School', 'College'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
              selectedSubCategory = null;
              selectedSubject = null;
              subjectOptions = [];
            });
          },
          icon: Icon(Icons.arrow_drop_down,
              color: isDarkMode ? Colors.white70 : Colors.grey),
          isExpanded: true,
          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
        ),
      );
    }

    Widget _buildFilterRow() {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.lightBlue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Fixed Filter label
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Filter', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              // Scrollable filters
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      _buildStyledDropdown(
                        child: _buildCategoryDropdown(),
                        isDarkMode: isDarkMode,
                      ),
                      SizedBox(width: 12),
                      if (selectedCategory != null)
                        _buildStyledDropdown(
                          child: _buildSubCategoryDropdown(),
                          isDarkMode: isDarkMode,
                        ),
                      SizedBox(width: 12),
                      if (selectedSubCategory != null)
                        _buildStyledDropdown(
                          child: _buildSubjectDropdown(),
                          isDarkMode: isDarkMode,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          _buildFilterRow(),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 220,
              maxHeight: 240,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (top3.length > 1)
                      Positioned(
                        left: constraints.maxWidth * 0.1,
                        top: 20,
                        child: _buildTopUser(top3[1], 2),
                      ),
                    if (top3.isNotEmpty)
                      Align(
                        alignment: Alignment.topCenter,
                        child: _buildTopUser(top3[0], 1),
                      ),
                    if (top3.length > 2)
                      Positioned(
                        right: constraints.maxWidth * 0.1,
                        top: 20,
                        child: _buildTopUser(top3[2], 3),
                      ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: remainingUsers.length,
              itemBuilder: (context, index) =>
                  _buildListUser(remainingUsers[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledDropdown(
      {required Widget child, required bool isDarkMode}) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[700] : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: isDarkMode ? Colors.grey[800] : Colors.white,
        ),
        child: child,
      ),
    );
  }

  Widget _buildTopUser(LeaderboardUser user, int displayRank) {
    final size = displayRank == 1 ? 90.0 : 70.0;
    final medalColor = displayRank == 1
        ? Colors.amber
        : displayRank == 2
            ? Colors.grey
            : const Color(0xFFCD7F32);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CircleAvatar(
              radius: size / 2,
              backgroundColor: medalColor.withOpacity(0.2),
              child: CircleAvatar(
                radius: (size / 2) - 4,
                backgroundImage: user.imageUrl != null
                    ? CachedNetworkImageProvider(user.imageUrl!)
                    : null,
                backgroundColor: Colors.white,
                child: user.imageUrl == null
                    ? Icon(Icons.person, size: size / 2 - 4, color: Colors.grey)
                    : null,
              ),
            ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: medalColor,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  displayRank.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            Text(
              user.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '${user.score}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.subject,
                style: const TextStyle(fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListUser(LeaderboardUser user) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.grey[200],
            backgroundImage: user.imageUrl != null
                ? CachedNetworkImageProvider(user.imageUrl!)
                : null,
            child: user.imageUrl == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#${user.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.school, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    user.subject,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.assessment, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '${user.score}% Accuracy',
                  style: TextStyle(
                    color: isDarkMode ? Colors.green[200] : Colors.green[800],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
