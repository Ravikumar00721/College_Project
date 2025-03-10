import 'package:flutter/material.dart';
import 'package:quiz_craft_ai/core/themes.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

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
                // TODO: Add edit profile functionality
              },
              icon: Icon(Icons.edit, color: Colors.white),
              label: Text("Edit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              height: 170, // Adjusted height for better UI
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
                  CircleAvatar(
                    maxRadius: 50.0,
                    backgroundColor: AppColors.background,
                    backgroundImage: AssetImage('assets/image/RaviKumar.jpeg'),
                  ),
                  SizedBox(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ravi Kumar",
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                      Text(
                        "BCA, SEC-A, 3rd Year",
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                    ],
                  )
                ],
              ),
            ),

            SizedBox(height: 20),

            // Personal Details
            _buildSectionTitle("Personal Details"),
            _buildInfoRow("Full Name", "Ravi Kumar"),
            _buildInfoRow("Date of Birth", "22 sep 2002"),
            _buildInfoRow("Gender", "Male"),

            // Academic Information
            _buildSectionTitle("Academic Information"),
            _buildInfoRow("Education Level", "College"),
            _buildInfoRow("Class/Year", "3rd Year BCA"),
            _buildInfoRow("College Name", "ABC University"),
            _buildInfoRow("Stream/Major", "Computer Science"),

            // Study Preferences
            _buildSectionTitle("Study Preferences"),
            _buildInfoRow("Subjects of Interest", "Mathematics, Programming"),
            _buildInfoRow("Learning Mode", "Visual & Quizzes"),
            _buildInfoRow("Daily Study Goal", "2 Hours"),

            // Contact Information
            _buildSectionTitle("Contact & Login Information"),
            _buildInfoRow("Email", "ravi.kumar@example.com"),
            _buildInfoRow("Phone Number", "+91 9876543210"),
            _buildInfoRow("Login Method", "Google"),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Center(
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
