import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/usermodel.dart';

class ProfileEditSheet extends ConsumerStatefulWidget {
  final VoidCallback onUpdate;

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
  late TextEditingController phoneController;

  String? selectedGender;
  String? selectedCategory; // Added category state
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchProfileFromFirestore();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    dobController = TextEditingController();
    collegeController = TextEditingController();
    classYearController = TextEditingController();
    streamController = TextEditingController();
    subjectsController = TextEditingController();
    phoneController = TextEditingController();
  }

  Future<void> _fetchProfileFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final profile = ProfileModel.fromMap(
            doc.id, // Pass document ID
            doc.data() as Map<String, dynamic>);
        setState(() {
          nameController.text = profile.fullName;
          dobController.text = profile.dateOfBirth;
          collegeController.text = profile.collegeName;
          classYearController.text = profile.classYear;
          streamController.text = profile.stream;
          phoneController.text = profile.phoneNumber;
          selectedGender = profile.gender;
          selectedCategory = profile.selectedCategory; // Initialize category
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate() && selectedCategory != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() => isLoading = true);

      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid) // Changed from user.email
            .get();

        String existingImagePath = doc.exists
            ? (doc.data() as Map<String, dynamic>)['profileImagePath'] ?? ""
            : "";

        ProfileModel updatedProfile = ProfileModel(
          fullName: nameController.text,
          dateOfBirth: dobController.text,
          gender: selectedGender ?? "Male",
          collegeName: collegeController.text,
          classYear: classYearController.text,
          stream: streamController.text,
          email: user.email!,
          phoneNumber: phoneController.text,
          profileImagePath: existingImagePath,
          selectedCategory: selectedCategory!, // Ensured non-null
        );

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid) // Changed from user.email
            .set(updatedProfile.toMap(), SetOptions(merge: true));

        widget.onUpdate();
        Navigator.pop(context);
      } catch (e) {
        print("Error updating profile: $e");
      } finally {
        setState(() => isLoading = false);
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
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  controller: scrollController,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDragHandle(),
                        const SizedBox(height: 10),
                        const Text("Edit Profile",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        _buildFormFields(),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField("Full Name", nameController, required: true),
        _buildDatePickerField("Date of Birth", dobController),
        _buildGenderDropdown(),
        _buildCategoryDropdown(),
        _buildTextField("College Name", collegeController, required: true),
        _buildTextField("Class/Year", classYearController, required: true),
        _buildTextField("Stream/Major", streamController),
        _buildTextField("Subjects", subjectsController),
        _buildTextField("Phone Number", phoneController, required: true),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        value: selectedCategory?.toLowerCase(), // Convert to lowercase
        decoration: const InputDecoration(
          labelText: "Category *",
          border: OutlineInputBorder(),
        ),
        items: const ["school", "college"] // Use lowercase values
            .map((category) => DropdownMenuItem(
                  value: category,
                  child:
                      Text(category[0].toUpperCase() + category.substring(1)),
                ))
            .toList(),
        onChanged: (value) => setState(() => selectedCategory = value),
        validator: (value) => value == null ? "Please select category" : null,
      ),
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
          border: const OutlineInputBorder(),
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
        decoration: const InputDecoration(
          labelText: "Date of Birth *",
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.blueGrey),
        ),
        onTap: () => _selectDate(context),
        validator: (value) => value?.isEmpty ?? true ? "Required field" : null,
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: const InputDecoration(
          labelText: "Gender *",
          border: OutlineInputBorder(),
        ),
        items: ["Male", "Female", "Others"]
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
            .toList(),
        onChanged: (value) => setState(() => selectedGender = value),
        validator: (value) => value == null ? "Please select gender" : null,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        onPressed: _updateProfile,
        child: const Text("Save Changes"),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = DateFormat('dd MMM yyyy').format(picked);
    }
  }
}
