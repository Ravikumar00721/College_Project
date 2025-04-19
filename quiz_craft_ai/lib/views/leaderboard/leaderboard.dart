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
          var programs = filterOptions['College'][selectedSubCategory];
          if (programs is! Map || !programs.containsKey(user.subCategory))
            return false;
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
        List<String> subjects = [];
        var programs = filterOptions['College'][subCategory];
        if (programs is Map<String, List<String>>) {
          programs.values.forEach(subjects.addAll);
        }
        return subjects;
      }
    }

    Widget _buildSubCategoryDropdown() {
      List<String> subCategories = [];
      if (selectedCategory == 'School') {
        subCategories =
            (filterOptions['School'] as Map).keys.toList().cast<String>();
      } else if (selectedCategory == 'College') {
        subCategories =
            (filterOptions['College'] as Map).keys.toList().cast<String>();
      }

      return DropdownButton<String>(
        hint: Text(selectedCategory == 'School'
            ? 'Select Class'
            : 'Select Program Type'),
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
      return DropdownButton<String>(
        hint: Text('Select Subject'),
        value: selectedSubject,
        items: subjectOptions
            .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                ))
            .toList(),
        onChanged: (value) => setState(() => selectedSubject = value),
      );
    }

    // Widget _buildDropdownWrapper(Widget child) {
    //   return SizedBox(
    //     width: 200,
    //     height: 70, // Height adjusted to match others
    //     child: InputDecorator(
    //       decoration: InputDecoration(
    //         border: OutlineInputBorder(
    //           borderRadius: BorderRadius.circular(8),
    //           borderSide: BorderSide.none,
    //         ),
    //         filled: true,
    //         fillColor: Colors.white,
    //         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    //       ),
    //       child: DropdownButtonHideUnderline(child: child),
    //     ),
    //   );
    // }

    Widget _buildCategoryDropdown() {
      return DropdownButton<String>(
        hint: Text('Select Category'),
        value: selectedCategory,
        items: ['School', 'College'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
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
