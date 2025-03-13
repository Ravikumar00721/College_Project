import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/usermodel.dart';
import '../../providers/user_provider.dart';

class CreateProfileBottomSheet extends ConsumerStatefulWidget {
  @override
  _CreateProfileBottomSheetState createState() =>
      _CreateProfileBottomSheetState();
}

class _CreateProfileBottomSheetState
    extends ConsumerState<CreateProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String? selectedGender;
  String email = "Loading..."; // Placeholder

  @override
  void initState() {
    super.initState();
    _fetchUserEmail(); // Get the current user's email
  }

  // ✅ Fetch Current User Email
  void _fetchUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? "No Email";
      });
    }
  }

  // ✅ Date Picker Function
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime(2015),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  // ✅ Submit Data to Firestore
  Future<void> _submitProfile() async {
    try {
      if (_formKey.currentState!.validate() && selectedGender != null) {
        // Create Profile Model with Default Values
        ProfileModel profile = ProfileModel(
          fullName: nameController.text.isNotEmpty
              ? nameController.text
              : "Guest User",
          dateOfBirth: dobController.text.isNotEmpty
              ? dobController.text
              : "01 Jan 2000",
          gender: selectedGender ?? "Male",
          collegeName: "Unknown College",
          classYear: "Unknown Year",
          stream: "Unknown Stream",
          subjects: "Not Specified",
          studyMode: "Self Study",
          dailyGoal: "1 Hour",
          email: email,
          phoneNumber: phoneController.text.isNotEmpty
              ? phoneController.text
              : "0000000000",
          loginMethod: "Manual",
          profileImagePath: "",
        );

        // Save to Firestore using Riverpod
        await ref.read(profileProvider.notifier).updateProfile(profile);

        // Close Bottom Sheet
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("🔥 Error saving profile: $e");

      // Show error message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save profile. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text("Create Your Profile",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  _buildTextField("Full Name", nameController,
                      required: true, type: "name"),
                  _buildDatePickerField("Date of Birth", dobController),
                  _buildGenderDropdown(),
                  _buildNonEditableField("Email", email), // Non-editable Email
                  _buildTextField("Phone Number", phoneController,
                      required: true, type: "phone"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitProfile, // Save to Firestore
                    child: Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ TextField with Validation
  Widget _buildTextField(String label, TextEditingController controller,
      {bool required = false, String type = "text"}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType:
            type == "phone" ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: required ? "$label *" : label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return "This field is required";
          }
          if (type == "name" &&
              !RegExp(r"^[a-zA-Z\s]{1,20}$").hasMatch(value!)) {
            return "Name should contain only letters (max 20 chars)";
          }
          if (type == "email" &&
              !RegExp(r"^[a-zA-Z0-9._%+-]+@gmail\.com$").hasMatch(value!)) {
            return "Enter a valid @gmail.com email";
          }
          return null;
        },
      ),
    );
  }

  // ✅ Date Picker Field
  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  // ✅ Gender Dropdown
  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
        validator: (value) =>
            value == null ? "Please select your gender" : null,
      ),
    );
  }

  // ✅ Non-Editable Email Field
  Widget _buildNonEditableField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "$label *",
          border: OutlineInputBorder(),
          fillColor: Colors.grey[200],
          filled: true,
        ),
      ),
    );
  }
}
