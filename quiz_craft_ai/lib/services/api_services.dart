import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/quizmodel.dart';
import '../providers/api_key.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref);
});

class ApiService {
  final String baseUrl =
      'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.3';
  final Ref ref;

  ApiService(this.ref);

  String get apiKey {
    final apiKey = ref.read(apiKeyProvider);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key not set. Please set it in the app settings.');
    }
    return apiKey;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QuizModel>> fetchProcessedText(String documentId) async {
    try {
      final extractedText = await _fetchTextFromFirestore(documentId);
      final wordCount = _countWords(extractedText);
      final quizCount = _calculateQuizCount(wordCount);
      final sanitizedText = _sanitizeInputText(extractedText);

      print("Word Count: $wordCount | QuizCount: $quizCount");
      print("Sanitized Text Length: ${sanitizedText.length}");

      // Build prompt using our builder function.
      final prompt = _buildPrompt(quizCount, sanitizedText);
      print("Built Prompt:\n$prompt");

      final response = await _sendToHuggingFace(prompt);
      return _parseResponse(response);
    } catch (e) {
      print('Error in fetchProcessedText: $e');
      rethrow;
    }
  }

  String _buildPrompt(int quizCount, String text) {
    return '''
Generate EXACTLY $quizCount questions. Use this EXACT format:

\`\`\`json
{
  "quizzes": [
    {
      "question": "What is deep learning?",
      "options": ["A...", "B...", "C...", "D..."],
      "correct": 0,
      "explanation": "Deep learning uses neural networks to learn complex patterns."
    }
    // ... exactly $quizCount objects in total
  ]
}
\`\`\`

Text (truncated to 1000 characters):
${_truncateText(text, 1000)}

Rules:
1. Use the "correct" field for the answer index (0-3).
2. Generate $quizCount distinct questions based on key concepts in the text.
3. Each question must have exactly 4 answer choices.
4. Every question MUST include a non-empty explanation that clearly justifies why the answer is right or wrong.
5. The output MUST be valid JSON containing ONLY the JSON structure as shown (no extra text).
6. Use double quotes for JSON syntax and escape special characters properly.
''';
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    // Truncate to the last space before maxLength to avoid cutting a word
    final index = text.lastIndexOf(' ', maxLength);
    return text.substring(0, index) + '...';
  }

  String _sanitizeInputText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'),
            ' ') // Replace multiple whitespaces with single space
        .replaceAll(RegExp(r'[^\x00-\x7F]'), '') // Remove non-ASCII characters
        .trim();
  }

  int _countWords(String text) {
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  int _calculateQuizCount(int wordCount) {
    const minQuestions = 1;
    const maxQuestions = 15;
    const wordsPerQuestion = 50;
    final calculated = (wordCount / wordsPerQuestion).ceil();
    print('Word Count: $wordCount | Calculated: $calculated');
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
            'max_new_tokens': 3500, // Adjust token limit if needed
            'wait_for_model': true,
            'truncation': 'only_first', // Truncate input, not output
            'return_full_text': false,
            'max_length': 4096,
          }
        }),
      );

      print('API Raw Response: ${response.body}');

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
      // Extract and complete JSON from the raw generated text.
      final jsonString = _completeJson(_extractJson(generated));
      print('Sanitized JSON:\n$jsonString');

      final parsed = jsonDecode(jsonString);

      if (parsed is Map && parsed.containsKey('quizzes')) {
        return (parsed['quizzes'] as List)
            .map((item) => _parseQuizItem(item))
            .toList();
      }
      if (parsed is List) {
        return parsed.map((item) => _parseQuizItem(item)).toList();
      }
      throw FormatException('Unexpected JSON structure');
    } catch (e, stack) {
      print('Full Parsing Error: $e\n$stack');
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
        ),
        correctOptionIndex: _parseCorrectIndex(map['correct']),
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
    // First, try to find the JSON object containing "quizzes"
    final quizzesRegex = RegExp(
      r'\{\s*"quizzes"\s*:\s*\[.*?\]\s*\}',
      dotAll: true,
      caseSensitive: false,
    );
    final quizzesMatch = quizzesRegex.firstMatch(text);
    if (quizzesMatch != null) {
      return text.substring(quizzesMatch.start, quizzesMatch.end);
    }

    // Fallback: try to find any JSON array
    final arrayRegex = RegExp(r'\[.*?\]', dotAll: true);
    final arrayMatch = arrayRegex.firstMatch(text);
    if (arrayMatch != null) {
      return text.substring(arrayMatch.start, arrayMatch.end);
    }

    // Final fallback using bracket counting
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
    // Attempt to balance brackets and braces.
    final openBraces = json.split('{').length - 1;
    final closeBraces = json.split('}').length - 1;
    final openBrackets = json.split('[').length - 1;
    final closeBrackets = json.split(']').length - 1;

    String completed = json;

    if (openBraces > closeBraces) {
      completed += '}' * (openBraces - closeBraces);
    } else if (closeBraces > openBraces) {
      completed = completed.substring(0, completed.lastIndexOf('}'));
    }
    if (openBrackets > closeBrackets) {
      completed += ']' * (openBrackets - closeBrackets);
    } else if (closeBrackets > openBrackets) {
      completed = completed.substring(0, completed.lastIndexOf(']'));
    }

    // Cleanup trailing commas before a closing bracket or brace.
    completed = completed.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');
    return completed.replaceAll(RegExp(r'[\r\n]+'), ' ');
  }

  String _cleanString(dynamic input) {
    if (input == null) return '';
    return input.toString().replaceAll('\n', ' ').trim();
  }
}
