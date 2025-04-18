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
  String? selectedCategory;

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

// Add this variable to track submission state
  bool _isSubmitting = false;

// Modified Submit Method
  Future<void> _submitProfile() async {
    try {
      setState(() => _isSubmitting = true);

      // Validate all form fields
      if (!_formKey.currentState!.validate()) {
        return; // Keep sheet open if validation fails
      }

      // Create Profile Model
      ProfileModel profile = ProfileModel(
        fullName: nameController.text,
        dateOfBirth: dobController.text,
        gender: selectedGender!,
        collegeName: "Unknown College",
        classYear: "Unknown Year",
        stream: "Unknown Stream",
        email: email,
        phoneNumber: phoneController.text,
        profileImagePath: "",
        selectedCategory: selectedCategory!,
      );

      // Save to Firestore
      await ref.read(profileProvider.notifier).updateProfile(profile);

      // Only close on successful submission
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Error saving profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save profile. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Block back button
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ❌ Optional: Remove this to prevent manual closing
                // Align(
                //   alignment: Alignment.topRight,
                //   child: IconButton(
                //     icon: Icon(Icons.close),
                //     onPressed: () => Navigator.pop(context),
                //   ),
                // ),

                Text(
                  "Create Your Profile",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                _buildTextField("Full Name", nameController,
                    required: true, type: "name"),
                _buildCategoryDropdown(),
                _buildDatePickerField("Date of Birth", dobController),
                _buildGenderDropdown(),
                _buildNonEditableField("Email", email),
                _buildTextField("Phone Number", phoneController,
                    required: true, type: "phone"),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitProfile,
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Add Category Dropdown
  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        decoration: InputDecoration(
          labelText: "Category *",
          border: OutlineInputBorder(),
        ),
        items: const ["School", "College"]
            .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedCategory = value;
          });
        },
        validator: (value) =>
            value == null ? "Please select your category" : null,
      ),
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
