import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/leader_board_model.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final List<LeaderboardUser> users = [
    LeaderboardUser(
      rank: 1,
      name: "Alice",
      score: 98,
      imageUrl: "https://avatar.iran.liara.run/public/35",
      category: "School",
      subCategory: "Class 9-10",
      subject: "Mathematics",
    ),
    LeaderboardUser(
      rank: 2,
      name: "Bob",
      score: 95,
      imageUrl: "https://avatar.iran.liara.run/public/35",
      category: "School",
      subCategory: "Class 11-12",
      subject: "Physics",
    ),
    LeaderboardUser(
      rank: 3,
      name: "Charlie",
      score: 93,
      imageUrl: "https://avatar.iran.liara.run/public/35",
      category: "College",
      subCategory: "Engineering",
      subject: "Computer Science",
    ),
    LeaderboardUser(
      rank: 4,
      name: "David",
      score: 91,
      imageUrl: "https://avatar.iran.liara.run/public/35",
      category: "School",
      subCategory: "Class 6-8",
      subject: "Science",
    ),
    LeaderboardUser(
      rank: 5,
      name: "Eva",
      score: 89,
      imageUrl: "https://avatar.iran.liara.run/public/35",
      category: "College",
      subCategory: "Commerce",
      subject: "Economics",
    ),
    LeaderboardUser(
      rank: 6,
      name: "Frank",
      score: 87,
      imageUrl: "https://avatar.iran.liara.run/public/35",
      category: "School",
      subCategory: "Class 9-10",
      subject: "English",
    ),
    LeaderboardUser(
      rank: 7,
      name: "Grace",
      score: 85,
      imageUrl: "https://avatar.iran.liara.run/public/35",
      category: "College",
      subCategory: "Arts & Humanities",
      subject: "History",
    ),
    LeaderboardUser(
      rank: 8,
      name: "Henry",
      score: 83,
      imageUrl: "https://avatar.iran.liara.run/public/35",
      category: "School",
      subCategory: "Class 11-12",
      subject: "Biology",
    ),
    LeaderboardUser(
      rank: 9,
      name: "Ivy",
      score: 81,
      imageUrl: "https://avatar.iran.liara.run/public/35",
      category: "College",
      subCategory: "Engineering",
      subject: "Mathematics",
    ),
    LeaderboardUser(
      rank: 10,
      name: "Jack",
      score: 79,
      imageUrl: "https://avatar.iran.liara.run/public/35",
      category: "School",
      subCategory: "Class 6-8",
      subject: "Social Science",
    ),
  ];

  // 1. Corrected filter options structure
  final Map<String, dynamic> filterOptions = {
    'School': {
      'Class 1-5 (Primary)': ['All Subjects'],
      'Class 6-8 (Middle School)': ['All Subjects'],
      'Class 9-10 (Secondary)': [
        'English',
        'Mathematics',
        'Science',
        'Social Science',
        'Computer Science'
      ],
      'Class 11-12 (Senior Secondary)': [
        'Physics',
        'Chemistry',
        'Mathematics',
        'Biology',
        'Accountancy',
        'Economics',
        'Business Studies',
        'History',
        'Political Science',
        'Geography'
      ],
    },
    'College': {
      'Undergraduate': [
        'Computer Science',
        'Economics',
        'History',
        'Physics',
        'Chemistry',
        'Mathematics',
        'Biology',
        'Accountancy',
        'Business Studies',
        'Political Science',
        'Geography'
      ],
      'Postgraduate': [
        'Computer Science',
        'Economics',
        'History',
        'Physics',
        'Chemistry',
        'Mathematics',
        'Biology',
        'Accountancy',
        'Business Studies',
        'Political Science',
        'Geography'
      ],
    }
  };

  // 3. Add Filter State Variables
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedSubject;
  List<String> subjectOptions = [];

  List<LeaderboardUser> get filteredUsers {
    return users.where((user) {
      bool matchesCategory =
          selectedCategory == null || user.category == selectedCategory;
      bool matchesSubCategory = selectedSubCategory == null ||
          user.subCategory == selectedSubCategory;
      bool matchesSubject =
          selectedSubject == null || user.subject == selectedSubject;

      return matchesCategory && matchesSubCategory && matchesSubject;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final top3 = users.take(3).toList();
    final remainingUsers = users.skip(3).toList();

    Widget _buildSubCategoryDropdown() {
      final subCategories =
          (filterOptions[selectedCategory] as Map<String, dynamic>)
              .keys
              .toList()
              .cast<String>();

      return SizedBox(
        width: 200,
        height: 70, // Fixed height added
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text('Sub-category', overflow: TextOverflow.ellipsis),
              value: selectedSubCategory,
              items: subCategories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedSubCategory = newValue;
                  selectedSubject = null;
                  final subjects = filterOptions[selectedCategory]![newValue];
                  subjectOptions =
                      subjects is List<dynamic> ? subjects.cast<String>() : [];
                });
              },
            ),
          ),
        ),
      );
    }

    Widget _buildSubjectDropdown() {
      return SizedBox(
        width: 200,
        height: 70, // Fixed height added
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text('Subject', overflow: TextOverflow.ellipsis),
              value: selectedSubject,
              items: subjectOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() => selectedSubject = newValue);
              },
            ),
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
              selectedSubject = null;
              subjectOptions = [];
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
            // Light blue container
            color: Colors.lightBlue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Filter',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    height: 70,
                    child: Row(
                      children: [
                        _buildCategoryDropdown(),
                        if (selectedCategory != null) SizedBox(width: 8),
                        if (selectedCategory != null)
                          _buildSubCategoryDropdown(),
                        if (selectedSubCategory != null &&
                            subjectOptions.isNotEmpty)
                          SizedBox(width: 8),
                        if (selectedSubCategory != null &&
                            subjectOptions.isNotEmpty)
                          _buildSubjectDropdown(),
                      ],
                    ),
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
        title: Text('Leaderboard'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
                final maxWidth = constraints.maxWidth;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // 2nd Place (Left)
                    if (top3.length > 1)
                      Positioned(
                        left: maxWidth * 0.1, // 10% from left
                        child: _buildTopUser(top3[1], 2),
                      ),

                    // 1st Place (Center)
                    if (top3.isNotEmpty)
                      Align(
                        alignment: Alignment.center,
                        child: _buildTopUser(top3[0], 1),
                      ),

                    // 3rd Place (Right)
                    if (top3.length > 2)
                      Positioned(
                        right: maxWidth * 0.1, // 10% from right
                        child: _buildTopUser(top3[2], 3),
                      ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 20),

          // Rest of the users in scrollable list
          Expanded(
            child: ListView.builder(
              itemCount: remainingUsers.length,
              itemBuilder: (context, index) {
                final user = remainingUsers[index];
                return _buildListUser(user);
              },
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
