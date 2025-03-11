import 'package:flutter/material.dart';

class ProfileEditSheet extends StatefulWidget {
  @override
  _ProfileEditSheetState createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();

  // Editable fields
  TextEditingController nameController =
      TextEditingController(text: "Ravi Kumar");
  TextEditingController dobController =
      TextEditingController(text: "22 Sep 2002");
  TextEditingController genderController = TextEditingController(text: "Male");
  TextEditingController collegeController =
      TextEditingController(text: "ABC University");
  TextEditingController classYearController =
      TextEditingController(text: "3rd Year BCA");
  TextEditingController streamController =
      TextEditingController(text: "Computer Science");
  TextEditingController subjectsController =
      TextEditingController(text: "Mathematics, Programming");
  TextEditingController studyModeController =
      TextEditingController(text: "Visual & Quizzes");
  TextEditingController dailyGoalController =
      TextEditingController(text: "2 Hours");
  TextEditingController emailController =
      TextEditingController(text: "ravi.kumar@example.com");
  TextEditingController phoneController =
      TextEditingController(text: "+91 9876543210");
  TextEditingController loginMethodController =
      TextEditingController(text: "Google");

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7, // Adjust to show more content initially
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  _buildTextField("Full Name", nameController, required: true),
                  _buildTextField("Date of Birth", dobController,
                      required: true),
                  _buildTextField("Gender", genderController, required: true),
                  _buildTextField("College Name", collegeController,
                      required: true),
                  _buildTextField("Class/Year", classYearController,
                      required: true),
                  _buildTextField("Stream/Major", streamController),
                  _buildTextField("Subjects of Interest", subjectsController),
                  _buildTextField("Learning Mode", studyModeController),
                  _buildTextField("Daily Study Goal", dailyGoalController),
                  _buildTextField("Email", emailController, required: true),
                  _buildTextField("Phone Number", phoneController,
                      required: true),
                  _buildTextField("Login Method", loginMethodController),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context); // Close the bottom sheet
                        // TODO: Save the updated data to the app state or backend
                      }
                    },
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
          labelStyle: TextStyle(
            color: required ? Colors.red : Colors.black,
            fontWeight: required ? FontWeight.bold : FontWeight.normal,
          ),
          border: OutlineInputBorder(),
        ),
        validator: required
            ? (value) => value!.isEmpty ? "This field is required" : null
            : null,
      ),
    );
  }
}
