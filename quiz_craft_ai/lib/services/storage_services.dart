import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
      bucket: "gs://trello-ed39c.appspot.com"); // ✅ Use your Firebase bucket

  // ✅ Upload Image and return download URL with Debugging
  Future<String?> uploadProfileImage(File imageFile) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("❌ Error: User is not logged in.");
      return null;
    }

    try {
      print("🛠 Preparing to upload image for user: ${user.uid}");

      String fileName = "profile_images/${user.uid}.jpg";
      Reference storageRef = _storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Debug: Listen for upload state changes
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            "📊 Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%");
      });

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {
        print("✅ Upload completed for $fileName");
      });

      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("🔗 Download URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("🔥 Error uploading image: $e");
      return null;
    }
  }
}
