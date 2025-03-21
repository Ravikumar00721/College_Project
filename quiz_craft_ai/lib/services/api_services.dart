import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/quizmodel.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  final String baseUrl =
      'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.3';
  final String apiKey = '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';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QuizModel>> fetchProcessedText(String documentId) async {
    try {
      final extractedText = await _fetchTextFromFirestore(documentId);
      final wordCount = _countWords(extractedText);
      final quizCount = _calculateQuizCount(wordCount);

      final response = await _sendToHuggingFace('''
Generate $quizCount multiple-choice quizzes about this text.
Return ONLY valid JSON following EXACTLY this structure:
[
  {
    "question": "Question text (escaped quotes)",
    "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
    "correctOptionIndex": 0,
    "explanation": "Explanation text"
  }
]
Important:
- Use double quotes ONLY
- Escape special characters with \\
- No markdown or extra text
- Maintain valid JSON syntax

Text to analyze ($wordCount words):
${extractedText.replaceAll('"', '\\"')}
''');

      // Now returns List<QuizModel>
      return _parseResponse(response);
    } catch (e) {
      print('Error in fetchProcessedText: $e');
      rethrow;
    }
  }

  int _countWords(String text) {
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  int _calculateQuizCount(int wordCount) {
    // Adjust these values as needed
    const minQuestions = 1;
    const maxQuestions = 10;
    const wordsPerQuestion = 50;

    final calculated = (wordCount / wordsPerQuestion).ceil();
    return calculated.clamp(minQuestions, maxQuestions);
  }

  Future<String> _fetchTextFromFirestore(String documentId) async {
    final doc = await _firestore.collection('textData').doc(documentId).get();
    if (!doc.exists) throw Exception('Document not found');
    return (doc.data() as Map<String, dynamic>)['extractedText'] ?? '';
  }

  Future<Map<String, dynamic>> _sendToHuggingFace(String inputText) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': inputText,
          'parameters': {
            'max_new_tokens': 500,
            'wait_for_model': true,
          }
        }),
      );

      print('API Raw Response: ${response.body}'); // Add raw response logging

      if (response.statusCode == 403) {
        throw Exception('Access denied - Check API key and model permissions');
      }

      if (response.statusCode == 503) {
        final estimated = jsonDecode(response.body)['estimated_time'] ?? 20;
        await Future.delayed(Duration(seconds: estimated));
        return _sendToHuggingFace(inputText);
      }

      if (response.statusCode != 200) {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }

      // Handle different response formats
      final dynamic jsonResponse = jsonDecode(response.body);
      if (jsonResponse is List) {
        return jsonResponse.first as Map<String, dynamic>;
      }
      return jsonResponse as Map<String, dynamic>;
    } catch (e) {
      print('API Communication Error: $e');
      rethrow;
    }
  }

  List<QuizModel> _parseResponse(Map<String, dynamic> response) {
    try {
      final generated = response['generated_text'] as String;
      print('Raw Generated Text:\n$generated');

      final jsonString = _extractJson(generated);
      print('Extracted JSON:\n$jsonString');

      if (jsonString.isEmpty)
        throw FormatException('No JSON found in response');

      final parsed = jsonDecode(jsonString);
      print('Parsed JSON Type: ${parsed.runtimeType}');

      if (parsed is List) {
        return parsed.map((item) => _parseQuizItem(item)).toList();
      }
      if (parsed is Map<String, dynamic>) {
        return [_parseQuizItem(parsed)];
      }

      throw FormatException('Unexpected JSON format');
    } catch (e) {
      print('Parsing Error: $e');
      rethrow;
    }
  }

  QuizModel _parseQuizItem(dynamic item) {
    try {
      final map = item as Map<String, dynamic>;
      return QuizModel(
        id: const Uuid().v4(),
        question: _cleanString(map['question'] ?? ''),
        options: List<String>.from(
          (map['options'] as List<dynamic>).map((e) => _cleanString(e)),
        ), // Added missing closing parenthesis
        correctOptionIndex: _parseCorrectIndex(map['correctOptionIndex']),
        explanation: _cleanString(map['explanation']),
      );
    } catch (e) {
      print('Failed to parse quiz item: $item');
      throw FormatException('Invalid quiz item format: $e');
    }
  }

  int _parseCorrectIndex(dynamic index) {
    if (index is int) return index;
    if (index is String) return int.tryParse(index) ?? 0;
    return 0;
  }

  String _extractJson(String text) {
    // Simplified regex without recursive patterns
    final jsonRegex = RegExp(
      r'(\{[^{}]*\})|(\[[^\[\]]*\])',
      dotAll: true,
      multiLine: true,
    );

    // Find all potential JSON matches
    final matches = jsonRegex.allMatches(text);

    if (matches.isNotEmpty) {
      // Select the longest match
      var bestMatch = matches.first;
      for (final match in matches) {
        if ((match.end - match.start) > (bestMatch.end - bestMatch.start)) {
          bestMatch = match;
        }
      }
      return text.substring(bestMatch.start, bestMatch.end);
    }

    // Fallback to bracket counting method
    return _findJsonByBracketCounting(text);
  }

  String _findJsonByBracketCounting(String text) {
    final chars = text.split('');
    int braceCount = 0;
    int bracketCount = 0;
    int startIndex = -1;
    int endIndex = -1;

    for (int i = 0; i < chars.length; i++) {
      if (chars[i] == '{' || chars[i] == '[') {
        if (startIndex == -1) startIndex = i;
        if (chars[i] == '{') braceCount++;
        if (chars[i] == '[') bracketCount++;
      } else if (chars[i] == '}' || chars[i] == ']') {
        if (chars[i] == '}') braceCount--;
        if (chars[i] == ']') bracketCount--;

        if (braceCount == 0 && bracketCount == 0 && startIndex != -1) {
          endIndex = i;
          break;
        }
      }
    }

    if (startIndex != -1 && endIndex != -1) {
      return text.substring(startIndex, endIndex + 1);
    }

    return '';
  }

  String _completeJson(String json) {
    try {
      jsonDecode(json);
      return json;
    } catch (e) {
      // Attempt to fix common issues
      final fixedJson = json
          .replaceAll(RegExp(r',\s*]'), ']') // Remove trailing commas
          .replaceAll(RegExp(r',\s*}'), '}') // Remove trailing commas
          .replaceAll(RegExp(r'\\"'), '"') // Fix escaped quotes
          .replaceAll(RegExp(r'“|”'), '"'); // Replace smart quotes

      // Add missing closing brackets
      final openBraces = fixedJson.split('{').length - 1;
      final closeBraces = fixedJson.split('}').length - 1;
      final openBrackets = fixedJson.split('[').length - 1;
      final closeBrackets = fixedJson.split(']').length - 1;

      var completedJson = fixedJson;
      if (openBraces > closeBraces) completedJson += '}';
      if (openBrackets > closeBrackets) completedJson += ']';

      return completedJson;
    }
  }

  String _cleanString(dynamic input) {
    if (input == null) return '';
    return input.toString().replaceAll('\n', ' ').trim();
  }
}
