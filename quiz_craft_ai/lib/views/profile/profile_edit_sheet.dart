import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/usermodel.dart';

class ProfileEditSheet extends ConsumerStatefulWidget {
  final VoidCallback onUpdate; // Callback to refresh profile after update

  const ProfileEditSheet({super.key, required this.onUpdate});

  @override
  _ProfileEditSheetState createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController dobController;
  late TextEditingController collegeController;
  late TextEditingController classYearController;
  late TextEditingController streamController;
  late TextEditingController subjectsController;
  late TextEditingController studyModeController;
  late TextEditingController dailyGoalController;
  late TextEditingController phoneController;

  String? selectedGender;
  bool isLoading = true; // ✅ Show loader until data is fetched

  @override
  void initState() {
    super.initState();
    _fetchProfileFromFirestore();
  }

  // ✅ Fetch Profile Data from Firestore
  Future<void> _fetchProfileFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.email) // Fetch using email
          .get();

      if (doc.exists) {
        final profile =
            ProfileModel.fromMap(doc.data() as Map<String, dynamic>);

        setState(() {
          nameController = TextEditingController(text: profile.fullName);
          dobController = TextEditingController(text: profile.dateOfBirth);
          collegeController = TextEditingController(text: profile.collegeName);
          classYearController = TextEditingController(text: profile.classYear);
          streamController = TextEditingController(text: profile.stream);
          subjectsController = TextEditingController(text: profile.subjects);
          studyModeController = TextEditingController(text: profile.studyMode);
          dailyGoalController = TextEditingController(text: profile.dailyGoal);
          phoneController = TextEditingController(text: profile.phoneNumber);
          selectedGender = profile.gender;
          isLoading = false; // Hide loader
        });
      }
    } catch (e) {
      print("🔥 Error fetching profile: $e");
    }
  }

  // ✅ Date Picker Function
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1), // Default selection
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat('dd MMM yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        isLoading = true; // Show loading indicator before updating
      });

      try {
        // 🔹 Fetch the current user profile to retain the existing image
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.email)
            .get();

        String existingImagePath = "";
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          existingImagePath = data['profileImagePath'] ?? ""; // Preserve image
        }

        ProfileModel updatedProfile = ProfileModel(
          fullName: nameController.text,
          dateOfBirth: dobController.text,
          gender: selectedGender ?? "Male",
          collegeName: collegeController.text,
          classYear: classYearController.text,
          stream: streamController.text,
          subjects: subjectsController.text,
          studyMode: studyModeController.text,
          dailyGoal: dailyGoalController.text,
          email: user.email!,
          phoneNumber: phoneController.text,
          loginMethod: "Manual",
          profileImagePath: existingImagePath, // 🔹 Retain existing image
        );

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.email)
            .set(updatedProfile.toMap(), SetOptions(merge: true));

        widget.onUpdate(); // ✅ Refresh Profile Screen
        Navigator.pop(context); // Close bottom sheet
      } catch (e) {
        print("🔥 Error updating profile: $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator()) // ✅ Show Loader
              : SingleChildScrollView(
                  controller: scrollController,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 10),
                        Container(
                          width: 60,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("Edit Profile",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        _buildTextField("Full Name", nameController,
                            required: true),
                        _buildDatePickerField("Date of Birth", dobController),
                        _buildGenderDropdown(),
                        _buildTextField("College Name", collegeController,
                            required: true),
                        _buildTextField("Class/Year", classYearController,
                            required: true),
                        _buildTextField("Stream/Major", streamController),
                        _buildTextField(
                            "Subjects of Interest", subjectsController),
                        _buildTextField("Learning Mode", studyModeController),
                        _buildTextField(
                            "Daily Study Goal", dailyGoalController),
                        _buildTextField("Phone Number", phoneController,
                            required: true),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _updateProfile,
                          child: Text("Save Changes"),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: required ? "$label *" : label,
          border: OutlineInputBorder(),
        ),
        validator: required
            ? (value) => value!.isEmpty ? "This field is required" : null
            : null,
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "$label *",
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.blueGrey),
        ),
        onTap: () => _selectDate(context),
        validator: (value) =>
            value == null || value.isEmpty ? "Date of Birth is required" : null,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: InputDecoration(
          labelText: "Gender *",
          border: OutlineInputBorder(),
        ),
        items: ["Male", "Female", "Others"]
            .map((gender) =>
                DropdownMenuItem(value: gender, child: Text(gender)))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedGender = value;
          });
        },
      ),
    );
  }
}
