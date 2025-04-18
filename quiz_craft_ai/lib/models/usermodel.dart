class ProfileModel {
  String fullName;
  String dateOfBirth;
  String gender;
  String collegeName;
  String classYear;
  String stream;
  String email;
  String phoneNumber;
  String profileImagePath;
  String selectedCategory;

  ProfileModel({
    this.fullName = "Guest User",
    this.dateOfBirth = "01 Jan 2000",
    this.gender = "Male",
    this.collegeName = "Unknown College",
    this.classYear = "Unknown Year",
    this.stream = "Unknown Stream",
    this.email = "guest@example.com",
    this.phoneNumber = "0000000000",
    this.profileImagePath = "",
    this.selectedCategory = "",
  });

  // ✅ Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      "fullName": fullName,
      "dateOfBirth": dateOfBirth,
      "gender": gender,
      "collegeName": collegeName,
      "classYear": classYear,
      "stream": stream,
      "email": email,
      "phoneNumber": phoneNumber,
      "profileImagePath": profileImagePath,
      "selectedCategory": selectedCategory,
    };
  }

  // ✅ Create ProfileModel from Map (for Firestore)
  factory ProfileModel.fromMap(Map<String, dynamic>? map) {
    return ProfileModel(
      fullName: map?["fullName"] ?? "Guest User",
      dateOfBirth: map?["dateOfBirth"] ?? "01 Jan 2000",
      gender: map?["gender"] ?? "Male",
      collegeName: map?["collegeName"] ?? "Unknown College",
      classYear: map?["classYear"] ?? "Unknown Year",
      stream: map?["stream"] ?? "Unknown Stream",
      email: map?["email"] ?? "guest@example.com",
      phoneNumber: map?["phoneNumber"] ?? "0000000000",
      profileImagePath: map?["profileImagePath"] ?? "",
      selectedCategory: map?["selectedCategory"] ?? "",
    );
  }

  // ✅ Add `copyWith` method to update fields
  ProfileModel copyWith({
    String? fullName,
    String? dateOfBirth,
    String? gender,
    String? collegeName,
    String? classYear,
    String? stream,
    String? email,
    String? phoneNumber,
    String? profileImagePath,
    String? selectedCategory,
    String? selectedSubCategory,
    String? selectedSubject,
  }) {
    return ProfileModel(
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      collegeName: collegeName ?? this.collegeName,
      classYear: classYear ?? this.classYear,
      stream: stream ?? this.stream,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
