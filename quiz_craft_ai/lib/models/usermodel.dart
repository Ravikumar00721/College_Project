class ProfileModel {
  String fullName;
  String dateOfBirth;
  String gender;
  String collegeName;
  String classYear;
  String stream;
  String subjects;
  String studyMode;
  String dailyGoal;
  String email;
  String phoneNumber;
  String loginMethod;
  String profileImagePath;

  ProfileModel({
    this.fullName = "Guest User",
    this.dateOfBirth = "01 Jan 2000",
    this.gender = "Male",
    this.collegeName = "Unknown College",
    this.classYear = "Unknown Year",
    this.stream = "Unknown Stream",
    this.subjects = "Not Specified",
    this.studyMode = "Self Study",
    this.dailyGoal = "1 Hour",
    this.email = "guest@example.com",
    this.phoneNumber = "0000000000",
    this.loginMethod = "Manual",
    this.profileImagePath = "",
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
      "subjects": subjects,
      "studyMode": studyMode,
      "dailyGoal": dailyGoal,
      "email": email,
      "phoneNumber": phoneNumber,
      "loginMethod": loginMethod,
      "profileImagePath": profileImagePath,
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
      subjects: map?["subjects"] ?? "Not Specified",
      studyMode: map?["studyMode"] ?? "Self Study",
      dailyGoal: map?["dailyGoal"] ?? "1 Hour",
      email: map?["email"] ?? "guest@example.com",
      phoneNumber: map?["phoneNumber"] ?? "0000000000",
      loginMethod: map?["loginMethod"] ?? "Manual",
      profileImagePath: map?["profileImagePath"] ?? "",
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
    String? subjects,
    String? studyMode,
    String? dailyGoal,
    String? email,
    String? phoneNumber,
    String? loginMethod,
    String? profileImagePath,
  }) {
    return ProfileModel(
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      collegeName: collegeName ?? this.collegeName,
      classYear: classYear ?? this.classYear,
      stream: stream ?? this.stream,
      subjects: subjects ?? this.subjects,
      studyMode: studyMode ?? this.studyMode,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      loginMethod: loginMethod ?? this.loginMethod,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
