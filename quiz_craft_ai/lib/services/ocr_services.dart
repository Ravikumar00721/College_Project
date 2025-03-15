import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart'; // Correct package
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRServices {
  /// 📌 Select an Image and Extract Text using OCR
  static Future<void> pickImageAndExtractText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Allows only image selection
    );

    if (result != null) {
      File imageFile = File(result.files.single.path!);
      String extractedText = await extractTextFromImage(imageFile);
      print("📝 Extracted Text from Image: \n$extractedText");
    } else {
      print("❌ No Image selected");
    }
  }

  /// 📌 Extract Text from an Image File using Google ML Kit
  static Future<String> extractTextFromImage(File imageFile) async {
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      await textRecognizer.close(); // Close recognizer to free resources
      return recognizedText.text;
    } catch (e) {
      print("🔥 Error extracting text from image: $e");
      return "Error extracting text";
    }
  }

  /// 📌 Select a PDF and Extract Text
  static Future<void> pickPDFAndExtractText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Allows only PDFs
    );

    if (result != null) {
      File pdfFile = File(result.files.single.path!);
      String extractedText = await extractTextFromPDF(pdfFile);
      print("📄 Extracted Text from PDF: \n$extractedText");
    } else {
      print("❌ No PDF selected");
    }
  }

  /// 📌 Extract Text from a PDF File using `flutter_pdf_text`
  static Future<String> extractTextFromPDF(File pdfFile) async {
    try {
      PDFDoc pdfDoc = await PDFDoc.fromFile(pdfFile);
      String text = await pdfDoc.text; // Extract text from entire PDF
      return text.trim().isEmpty ? "⚠ No text found in PDF" : text;
    } catch (e) {
      print("🔥 Error extracting text from PDF: $e");
      return "Error extracting text from PDF";
    }
  }
}
