import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_craft_ai/services/auth_services.dart';

import '../../core/themes.dart'; // Import color theme

class HomeScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser; // Get logged-in user

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primary, // Use defined color
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
      drawer: Drawer(
        backgroundColor: AppColors.background, // Use defined color
        child: Column(
          children: [
            // Custom Drawer Header
            Container(
              height: 200,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondary, // Use soft pink header color
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Profile Icon on Left
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.accent, // Teal Profile Icon
                    child: Icon(Icons.person, color: Colors.black, size: 32),
                  ),
                  SizedBox(width: 16),
                  // Name & Email aligned to left
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Guest User", // Use default name if null
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user?.email ?? "user@example.com",
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
            // Drawer Tiles
            ListTile(
              leading:
                  Icon(Icons.person, color: AppColors.primary), // Cyan icon
              title: Text("My Profile",
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                context.go('/myprofile');
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.logout, color: AppColors.primary), // Cyan icon
              title: Text("Sign Out",
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () async {
                await authService.signOut();
                context.go("/login");
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: AppColors.background, // Light green background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.home,
                  size: 80, color: AppColors.primary), // Cyan home icon
              SizedBox(height: 20),
              Text(
                "Welcome, ${user?.email ?? 'User'}!",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await authService.signOut();
                  context.go("/login");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Cyan button
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text("Sign Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
