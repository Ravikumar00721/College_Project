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
  String email = "Loading...";
  String? selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  void _fetchUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => email = user.email ?? "No Email");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime(2015),
    );
    if (pickedDate != null) {
      setState(() =>
          dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate));
    }
  }

  Future<void> _submitProfile() async {
    try {
      print('[DEBUG] Starting profile submission');
      setState(() => _isSubmitting = true);
      if (!_formKey.currentState!.validate()) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      print('[DEBUG] Creating profile for: ${user.uid}');
      final profile = ProfileModel(
        userId: user.uid,
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

      print('[DEBUG] Saving to Firestore...');
      await ref.read(profileProvider.notifier).updateProfile(profile);
      print('[DEBUG] Firestore save successful');
      Navigator.of(context).pop(true);
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: ${e.toString()}")),
      );
      Navigator.of(context).pop(false); // Pop with false on error
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  "Create Your Profile",
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                _buildTextField("Full Name", nameController, required: true),
                _buildCategoryDropdown(),
                _buildDatePickerField(),
                _buildGenderDropdown(),
                _buildNonEditableField("Email", email),
                _buildTextField("Phone Number", phoneController,
                    required: true, isPhone: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text("Submit", style: textTheme.labelLarge),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool required = false, bool isPhone = false}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.name,
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: required ? "$label *" : label,
          border: const OutlineInputBorder(),
          labelStyle:
              TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
          fillColor: theme.colorScheme.surfaceVariant,
          filled: true,
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return "This field is required";
          }
          if (label == "Full Name" &&
              !RegExp(r"^[a-zA-Z\s]{1,20}$").hasMatch(value!)) {
            return "Name should contain only letters (max 20 chars)";
          }
          if (isPhone && !RegExp(r"^[0-9]{10}$").hasMatch(value!)) {
            return "Enter a valid 10-digit phone number";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        decoration: InputDecoration(
          labelText: "Category *",
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
          fillColor: theme.colorScheme.surfaceVariant,
          filled: true,
        ),
        items: const ["School", "College"]
            .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(
                    category,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ))
            .toList(),
        onChanged: (value) => setState(() => selectedCategory = value),
        style: TextStyle(color: theme.colorScheme.onSurface),
        dropdownColor: theme.colorScheme.surface,
        validator: (value) =>
            value == null ? "Please select your category" : null,
      ),
    );
  }

  Widget _buildDatePickerField() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: dobController,
        readOnly: true,
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: "Date of Birth *",
          border: const OutlineInputBorder(),
          suffixIcon:
              Icon(Icons.calendar_today, color: theme.colorScheme.primary),
          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
          fillColor: theme.colorScheme.surfaceVariant,
          filled: true,
        ),
        onTap: () => _selectDate(context),
        validator: (value) =>
            value?.isEmpty ?? true ? "Date of Birth is required" : null,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: InputDecoration(
          labelText: "Gender *",
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
          fillColor: theme.colorScheme.surfaceVariant,
          filled: true,
        ),
        items: ["Male", "Female", "Others"]
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender,
                      style: TextStyle(color: theme.colorScheme.onSurface)),
                ))
            .toList(),
        onChanged: (value) => setState(() => selectedGender = value),
        style: TextStyle(color: theme.colorScheme.onSurface),
        dropdownColor: theme.colorScheme.surface,
        validator: (value) =>
            value == null ? "Please select your gender" : null,
      ),
    );
  }

  Widget _buildNonEditableField(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: "$label *",
          border: const OutlineInputBorder(),
          fillColor: theme.colorScheme.surfaceVariant,
          filled: true,
          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}
