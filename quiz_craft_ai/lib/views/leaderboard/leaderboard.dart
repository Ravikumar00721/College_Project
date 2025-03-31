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
      subCategory: "B.Tech",
      subject: "Data Science",
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
  // 3. Add Filter State Variables
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedSubject;
  List<String> subjectOptions = [];
  String? selectedProgram; // Track selected college program separately

  List<LeaderboardUser> get filteredUsers {
    return users.where((user) {
      // 1. First match the category (School/College)
      if (selectedCategory != null && user.category != selectedCategory) {
        return false;
      }

      // 2. Handle School category filtering
      if (selectedCategory == 'School') {
        // Match sub-category (class level)
        if (selectedSubCategory != null &&
            user.subCategory != selectedSubCategory) {
          return false;
        }
        // Match subject
        if (selectedSubject != null && user.subject != selectedSubject) {
          return false;
        }
        return true;
      }
      // 3. Handle College category filtering
      else if (selectedCategory == 'College') {
        // For college, we need to match both program and subject

        // First check if we have a program selected
        if (selectedProgram != null && user.subCategory != selectedProgram) {
          return false;
        }

        // Then check if we have a subject selected
        if (selectedSubject != null && user.subject != selectedSubject) {
          return false;
        }

        return true;
      }

      // If no category is selected, show all users
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedUsers = filteredUsers;
    final top3 = displayedUsers.take(3).toList();
    final remainingUsers = displayedUsers.skip(3).toList();

    // UPDATED SUB-CATEGORY DROPDOWN HANDLER
    Widget _buildSubCategoryDropdown() {
      List<String> subCategories = [];

      if (selectedCategory == 'College') {
        // For College, show degrees (Undergraduate/Postgraduate)
        subCategories =
            (filterOptions[selectedCategory] as Map<String, dynamic>)
                .keys
                .toList()
                .cast<String>();
      } else {
        subCategories =
            (filterOptions[selectedCategory] as Map<String, dynamic>?)
                    ?.keys
                    .toList()
                    .cast<String>() ??
                [];
      }

      return SizedBox(
        width: 200,
        height: 70,
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text('Sub-category'),
              value: selectedSubCategory,
              items: subCategories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue == null) return;
                setState(() {
                  selectedSubCategory = newValue;
                  selectedProgram = null; // Reset program selection
                  selectedSubject = null;

                  if (selectedCategory == 'College') {
                    // For College, load programs (B.Tech, BCA, etc.) into subjectOptions
                    final degreeData = filterOptions[selectedCategory]
                        ?[newValue] as Map<String, dynamic>?;
                    if (degreeData != null) {
                      subjectOptions = degreeData.keys.toList().cast<String>();
                    }
                  } else {
                    // Existing logic for School
                    final subjectsData =
                        filterOptions[selectedCategory]?[newValue];
                    if (subjectsData is List<dynamic>) {
                      subjectOptions = subjectsData.cast<String>();
                    } else if (subjectsData is Map<String, dynamic>) {
                      subjectOptions = subjectsData.values
                          .expand((subList) =>
                              (subList as List<dynamic>).cast<String>())
                          .toList();
                    }
                  }
                });
              },
            ),
          ),
        ),
      );
    }

    Widget _buildSchoolSubjectDropdown() {
      List<String> options = [];
      String hintText = 'Subject';

      if (selectedCategory == 'College' && selectedSubCategory != null) {
        final degreeData = filterOptions['College'][selectedSubCategory]
            as Map<String, dynamic>?;

        if (degreeData != null) {
          // Check if selectedSubject exists in the current options
          bool isProgramSelected = degreeData.containsKey(selectedSubject);

          if (isProgramSelected) {
            // Show subjects for the selected program
            hintText = 'Subject';
            options =
                (degreeData[selectedSubject] as List<dynamic>).cast<String>();
          } else {
            // Show programs list
            hintText = 'Program';
            options = degreeData.keys.toList().cast<String>();
          }
        }
      } else if (selectedCategory == 'School' && selectedSubCategory != null) {
        // Handle School category subjects
        final subjectsData =
            filterOptions[selectedCategory]?[selectedSubCategory];
        if (subjectsData is List<dynamic>) {
          options = subjectsData.cast<String>();
        } else if (subjectsData is Map<String, dynamic>) {
          options = subjectsData.values
              .expand((subList) => (subList as List<dynamic>).cast<String>())
              .toList();
        }
      }

      // Ensure the selectedSubject exists in current options
      final validSelectedSubject =
          options.contains(selectedSubject) ? selectedSubject : null;

      return SizedBox(
        width: 200,
        height: 70,
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: hintText,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(hintText),
              value: validSelectedSubject,
              items: options
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedSubject = newValue;
                });
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
              selectedProgram = null; // Reset program selection
              selectedSubject = null;
            });
          },
        ),
      );
    }

    Widget _buildProgramDropdown() {
      final degreeData = filterOptions['College']?[selectedSubCategory]
          as Map<String, dynamic>?;
      final programs = degreeData?.keys.toList() ?? [];

      return SizedBox(
        width: 200,
        height: 70,
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: 'Program',
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text('Select Program'),
              value: selectedProgram,
              items: programs.map((program) {
                return DropdownMenuItem<String>(
                  value: program,
                  child: Text(program),
                );
              }).toList(),
              onChanged: (newProgram) {
                setState(() {
                  selectedProgram = newProgram;
                  selectedSubject = null; // Reset subject when program changes
                });
              },
            ),
          ),
        ),
      );
    }

    Widget _buildCollegeSubjectDropdown() {
      final degreeData = filterOptions['College']?[selectedSubCategory]
          as Map<String, dynamic>?;
      final subjects = degreeData?[selectedProgram] as List<dynamic>? ?? [];

      return SizedBox(
        width: 200,
        height: 70,
        child: InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            hintText: 'Subject',
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text('Select Subject'),
              value: selectedSubject,
              items: subjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject.toString(),
                  child: Text(subject.toString()),
                );
              }).toList(),
              onChanged: (newSubject) {
                setState(() {
                  selectedSubject = newSubject;
                });
              },
            ),
          ),
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
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryDropdown(),
                      if (selectedCategory != null) SizedBox(width: 8),
                      if (selectedCategory != null) _buildSubCategoryDropdown(),
                      if (selectedCategory == 'College' &&
                          selectedSubCategory != null)
                        SizedBox(width: 8),
                      if (selectedCategory == 'College' &&
                          selectedSubCategory != null)
                        _buildProgramDropdown(),
                      if (selectedCategory == 'College' &&
                          selectedProgram != null)
                        SizedBox(width: 8),
                      if (selectedCategory == 'College' &&
                          selectedProgram != null)
                        _buildCollegeSubjectDropdown(),
                      if (selectedCategory == 'School' &&
                          selectedSubCategory != null)
                        SizedBox(width: 8),
                      if (selectedCategory == 'School' &&
                          selectedSubCategory != null)
                        _buildSchoolSubjectDropdown(),
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
