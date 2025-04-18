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
  // 3. Add Filter State Variables
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedSubject;
  List<String> subjectOptions = [];
  String? selectedProgram; // Track selected college program separately

  @override
  void initState() {
    super.initState();
    _loadLeaderboardData();
  }

  Future<void> _loadLeaderboardData() async {
    final authService = AuthService();
    List<QuizResult> allResults = await authService.getAllQuizResults();

    Map<String, List<QuizResult>> groupedResults = {};

    for (var result in allResults) {
      // 1. Validate subcategory before splitting
      String category =
          result.selectedSubCategory.startsWith('Class') ? 'School' : 'College';

      // 2. Ensure key parts don't contain unexpected underscores
      String sanitizedSubCategory =
          result.selectedSubCategory.replaceAll('_', '-');
      String sanitizedSubject = result.selectedSubject.replaceAll('_', '-');

      String key =
          '${result.userId}_${category}_${sanitizedSubCategory}_${sanitizedSubject}';

      groupedResults.putIfAbsent(key, () => []).add(result);
    }

    List<LeaderboardUser> leaderboardUsers = [];

    // 3. Iterate through map entries safely
    for (var entry in groupedResults.entries) {
      List<String> keyParts = entry.key.split('_');

      // 4. Add bounds checking for key parts
      if (keyParts.length < 4) {
        print('Invalid key format: ${entry.key}');
        continue;
      }

      String userId = keyParts[0];
      String category = keyParts[1];
      String subCategory =
          keyParts[2].replaceAll('-', '_'); // Revert sanitization
      String subject = keyParts.sublist(3).join('_').replaceAll('-', '_');

      // 5. Handle empty result lists
      if (entry.value.isEmpty) continue;

      double totalScore =
          entry.value.fold(0, (sum, result) => sum + result.score);
      int averageScore = (totalScore / entry.value.length).round();

      ProfileModel? profile = await authService.getUserById(userId);
      if (profile == null) continue;

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

    // 6. Sort descending by score
    leaderboardUsers.sort((a, b) => b.score.compareTo(a.score));

    // 7. Assign ranks
    for (int i = 0; i < leaderboardUsers.length; i++) {
      leaderboardUsers[i] = leaderboardUsers[i].copyWith(rank: i + 1);
    }

    setState(() {
      users = leaderboardUsers;
      isLoading = false;
    });
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
      'Undergraduate Programs': {
        // ✅ Map with program-to-subjects mapping
        'Programming': ['Programming', 'Database', 'Web Development'],
        'Mechanical Engineering': ['Mechanical Engineering', 'Thermodynamics'],
        // Add all programs as key-value pairs
      },
      'Postgraduate Programs': {
        // ✅ Map with program-to-subjects mapping
        'Advanced Programming': ['Cloud Computing', 'Big Data'],
        'AI & ML': ['Neural Networks', 'Deep Learning'],
        // Add all programs as key-value pairs
      }
    }
  };

  List<LeaderboardUser> get filteredUsers {
    return users.where((user) {
      // 1. Category filter
      if (selectedCategory != null && user.category != selectedCategory) {
        return false;
      }

      // 2. Sub-category filter
      if (selectedSubCategory != null &&
          user.subCategory != selectedSubCategory) {
        return false;
      }

      // 3. Subject filter
      if (selectedSubject != null && user.subject != selectedSubject) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    final displayedUsers = filteredUsers;
    final top3 = displayedUsers.take(3).toList();
    final remainingUsers = displayedUsers.skip(3).toList();

    // FIX 2: Correct program name retrieval for college
    List<String> getSubjectsForSubCategory(String subCategory) {
      if (selectedCategory == 'School') {
        dynamic result = filterOptions['School'][subCategory];
        return result is List<String> ? result : [];
      } else if (selectedCategory == 'College') {
        List<String> subjects = [];
        var undergrad =
            filterOptions['College']['Undergraduate Programs'][subCategory];
        var postgrad =
            filterOptions['College']['Postgraduate Programs'][subCategory];
        if (undergrad is List<String>) subjects.addAll(undergrad);
        if (postgrad is List<String>) subjects.addAll(postgrad);
        return subjects;
      }
      return [];
    }

    // FIX 3: Simplify dropdown builders to avoid Set operations
    Widget _buildSubCategoryDropdown() {
      List<String> subCategories = [];
      if (selectedCategory == 'College') {
        subCategories = [
          ...(filterOptions['College']['Undergraduate Programs'] as Map).keys,
          ...(filterOptions['College']['Postgraduate Programs'] as Map).keys,
        ];
      } else if (selectedCategory == 'School') {
        subCategories =
            (filterOptions['School'] as Map).keys.toList().cast<String>();
      }

      return DropdownButton<String>(
        hint: Text(
            selectedCategory == 'School' ? 'Select Class' : 'Select Program'),
        value: selectedSubCategory,
        items: subCategories
            .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedSubCategory = value;
            selectedSubject = null;
            subjectOptions = getSubjectsForSubCategory(value!);
          });
        },
      );
    }

    Widget _buildSubjectDropdown() {
      return SizedBox(
        width: 200,
        height: 70,
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text('Select Subject'),
            value: selectedSubject,
            items: subjectOptions.map((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) => setState(() => selectedSubject = newValue),
          ),
        ),
      );
    }

    Widget _buildDropdownWrapper(Widget child) {
      return SizedBox(
        width: 200,
        height: 70, // Height adjusted to match others
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: DropdownButtonHideUnderline(child: child),
        ),
      );
    }

    Widget _buildCategoryDropdown() {
      return _buildDropdownWrapper(
        DropdownButton<String>(
          isExpanded: true,
          hint: Text('Category', overflow: TextOverflow.ellipsis),
          value: selectedCategory,
          items: ['School', 'College'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedCategory = newValue;
              selectedSubCategory = null;
              selectedProgram = null; // Reset program selection
              selectedSubject = null;
            });
          },
        ),
      );
    }

    Widget _buildFilterRow() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.lightBlue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
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
                SizedBox(width: 12),
                _buildCategoryDropdown(),
                SizedBox(width: 12),
                if (selectedCategory != null) _buildSubCategoryDropdown(),
                SizedBox(width: 12),
                if (selectedSubCategory != null) _buildSubjectDropdown(),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          _buildFilterRow(),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (top3.length > 1)
                      Positioned(
                        left: constraints.maxWidth * 0.1,
                        child: _buildTopUser(top3[1], 2),
                      ),
                    if (top3.isNotEmpty)
                      Align(
                        alignment: Alignment.center,
                        child: _buildTopUser(top3[0], 1),
                      ),
                    if (top3.length > 2)
                      Positioned(
                        right: constraints.maxWidth * 0.1,
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

  Widget _buildTopUser(LeaderboardUser user, int displayRank) {
    final size = displayRank == 1 ? 100.0 : 80.0;
    final medalColor = displayRank == 1
        ? Colors.amber
        : displayRank == 2
            ? Colors.grey
            : Color(0xFFCD7F32); // Bronze

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Medal badge
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: medalColor.withOpacity(0.2),
            border: Border.all(color: medalColor, width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // User avatar
              CircleAvatar(
                radius: size / 2,
                backgroundColor: Colors.grey[200],
                backgroundImage: user.imageUrl != null
                    ? CachedNetworkImageProvider(user.imageUrl!)
                    : null,
                child: user.imageUrl == null
                    ? Icon(Icons.person, size: size / 2)
                    : null,
              ),

              // Rank badge
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: medalColor,
                  ),
                  child: Text(
                    displayRank.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),

        // Name and score
        Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
        Text('${user.score}%', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildListUser(LeaderboardUser user) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage: user.imageUrl != null
              ? CachedNetworkImageProvider(user.imageUrl!)
              : null,
          child: user.imageUrl == null ? Icon(Icons.person) : null,
        ),
        title: Text(user.name),
        subtitle: Text('Accuracy: ${user.score}%'),
        trailing: Text('#${user.rank}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
