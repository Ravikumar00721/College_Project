import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;

class OCRServices {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<Map<String, String>?> pickImageAndExtractText(
      BuildContext context) async {
    try {
      // Show a dialog to choose between camera and gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Select Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return null; // User canceled

      // Pick image
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile == null) return null; // No image selected

      final imageFile = File(pickedFile.path);
      final fileName = pickedFile.name;
      final extractedText = await extractTextFromImage(imageFile);

      return {
        'fileName': fileName,
        'extractedText': extractedText,
      };
    } catch (e) {
      print("🔥 Image processing error: $e");
      return {'fileName': "", 'extractedText': "Error: ${e.toString()}"};
    }
  }

  /// 📌 Extract Text from an Image File using Google ML Kit
  static Future<String> extractTextFromImage(File imageFile) async {
    final textRecognizer = TextRecognizer();
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      print("🔥 Error extracting text from image: $e");
      return "Error extracting text";
    } finally {
      await textRecognizer.close();
    }
  }

  /// 📌 Updated PDF Handler
  static Future<Map<String, String>?> pickPDFAndExtractText() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final pdfFile = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final extractedText = await extractTextFromPDF(pdfFile);

        return {
          'fileName': fileName,
          'extractedText': extractedText,
        };
      }
      return null;
    } catch (e) {
      print("🔥 PDF processing error: $e");
      return {'fileName': "", 'extractedText': "Error: ${e.toString()}"};
    }
  }

  /// 📌 Extract Text from a PDF File using Syncfusion and OCR fallback
  static Future<String> extractTextFromPDF(File pdfFile) async {
    try {
      final document =
          syncfusion.PdfDocument(inputBytes: pdfFile.readAsBytesSync());
      String extractedText;

      try {
        extractedText = syncfusion.PdfTextExtractor(document).extractText();
      } catch (e) {
        print("⚠ Syncfusion text extraction failed: $e");
        extractedText = "";
      }

      document.dispose();

      if (extractedText.trim().isEmpty) {
        print("⚠ Trying OCR for scanned PDF...");
        extractedText = await extractTextFromScannedPDF(pdfFile);
      }

      return extractedText.trim().isEmpty
          ? "⚠ No text found in PDF"
          : extractedText;
    } catch (e) {
      print("🔥 Error extracting text from PDF: $e");
      return "Error extracting text from PDF";
    }
  }

  static Future<String> extractTextFromScannedPDF(File pdfFile) async {
    final textRecognizer = TextRecognizer();
    try {
      final document = await pdfx.PdfDocument.openFile(pdfFile.path);
      final StringBuffer extractedText = StringBuffer();

      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        try {
          final pdfImage = await page.render(
            width: page.width,
            height: page.height,
            format: pdfx.PdfPageImageFormat.png,
          );

          if (pdfImage != null) {
            // Remove unnecessary cast
            final Uint8List imageBytes = pdfImage.bytes;

            // Create temporary file
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/page_$i.png');

            // Remove unnecessary cast here
            await tempFile.writeAsBytes(imageBytes);

            // Extract text from the image file
            final text = await extractTextFromImage(tempFile);
            extractedText.writeln(text);

            // Clean up temporary file
            await tempFile.delete();
          }
        } catch (e) {
          print("⚠ Error processing page $i: $e");
        } finally {
          await page.close();
        }
      }

      await document.close();
      return extractedText.toString().trim().isEmpty
          ? "⚠ No text found in scanned PDF"
          : extractedText.toString();
    } catch (e) {
      print("🔥 Error extracting text from scanned PDF: $e");
      return "Error extracting text from scanned PDF";
    } finally {
      await textRecognizer.close();
    }
  }
}
