import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;

class OCRServices {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from camera or gallery and extract text using ML Kit.
  static Future<Map<String, String>?> pickImageAndExtractText(
      BuildContext context) async {
    try {
      // Prompt the user to choose an image source.
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

      // Pick the image from the chosen source.
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

  /// Extract text from an image file using Google ML Kit.
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

  /// Pick a PDF file and extract text from it.
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

  /// Enhanced PDF text extraction with detailed logging
  static Future<String> extractTextFromPDF(File pdfFile) async {
    syncfusion.PdfDocument? document;
    try {
      print("📄 Starting PDF processing for: ${pdfFile.path}");
      print("📄 File size: ${pdfFile.lengthSync()} bytes");

      // Read PDF bytes
      final pdfBytes = await pdfFile.readAsBytes();
      print("📄 PDF bytes length: ${pdfBytes.length}");

      // Try Syncfusion text extraction
      document = syncfusion.PdfDocument(inputBytes: pdfBytes);
      print("📄 Document pages: ${document.pages.count}");

      String extractedText;
      try {
        final textExtractor = syncfusion.PdfTextExtractor(document);
        extractedText = textExtractor.extractText();
        print("📄 Syncfusion extracted ${extractedText.length} characters");
      } catch (e) {
        print("⚠ Syncfusion text extraction failed: $e");
        extractedText = "";
      }

      document.dispose();

      // Fallback to OCR if no text found
      if (extractedText.trim().isEmpty) {
        print("🔄 No text found via Syncfusion, trying OCR...");
        final ocrText = await extractTextFromScannedPDF(pdfFile);
        print("📄 OCR extracted ${ocrText.length} characters");
        return ocrText;
      }

      return extractedText;
    } catch (e) {
      print("🔥 PDF processing error: $e");
      return "Error extracting text from PDF: ${e.toString()}";
    } finally {
      document?.dispose();
    }
  }

  /// Enhanced scanned PDF processing with detailed logging
  static Future<String> extractTextFromScannedPDF(File pdfFile) async {
    final textRecognizer = TextRecognizer();
    pdfx.PdfDocument? document;
    try {
      print("🔍 Starting OCR processing for: ${pdfFile.path}");
      document = await pdfx.PdfDocument.openFile(pdfFile.path);
      final totalPages = document.pagesCount;
      print("🔍 Total pages: $totalPages");

      final StringBuffer extractedText = StringBuffer();
      int processedPages = 0;

      for (int i = 1; i <= totalPages; i++) {
        print("🔍 Processing page $i/$totalPages");
        final page = await document.getPage(i);
        try {
          // To this
          final pdfImage = await page.render(
            width: page.width / 2, // Use regular division
            height: page.height / 2,
            format: pdfx.PdfPageImageFormat.jpeg,
            quality: 85,
          );

          if (pdfImage == null) {
            print("⚠ No image rendered for page $i");
            continue;
          }

          // Save temporary image
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/page_$i.jpg');
          print("📸 Saving temp image: ${tempFile.path}");
          await tempFile.writeAsBytes(pdfImage.bytes);

          // OCR processing
          print("🖼️ Extracting text from page $i image");
          final text = await extractTextFromImage(tempFile);
          print("📝 Page $i text length: ${text.length}");

          extractedText.writeln(text);
          processedPages++;

          // Cleanup
          await tempFile.delete();
        } catch (e) {
          print("⚠ Error processing page $i: $e");
        } finally {
          await page.close();
        }
      }

      await document.close();
      print("✅ OCR processed $processedPages/$totalPages pages successfully");

      final resultText = extractedText.toString().trim();
      return resultText.isEmpty ? "No text found in scanned PDF" : resultText;
    } catch (e) {
      print("🔥 OCR processing failed: $e");
      return "OCR processing failed: ${e.toString()}";
    } finally {
      await document?.close();
      await textRecognizer.close();
    }
  }
}
