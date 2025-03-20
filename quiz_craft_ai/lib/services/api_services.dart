import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/quizmodel.dart';

final apiServiceProvider = Provider((ref) => ApiService());
const String apiKey = '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';

class ApiService {
  // Correct API endpoint for inference
  final String baseUrl =
      'https://api-inference.huggingface.co/models/deepseek-ai/DeepSeek-R1';

  Future<Map<String, dynamic>> _sendToHuggingFace(String inputText) async {
    final uri = Uri.parse(baseUrl);
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    // Updated request body format
    final body = jsonEncode({
      "inputs": inputText,
      "parameters": {
        "return_full_text": false, // Get only the generated text
        "max_new_tokens": 500
      }
    });

    var response = await http.post(uri, headers: headers, body: body);

    // Handle model loading scenario
    if (response.statusCode == 503) {
      final estimatedTime = jsonDecode(response.body)['estimated_time'];
      await Future.delayed(Duration(seconds: estimatedTime.round()));
      response = await http.post(uri, headers: headers, body: body);
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Improved JSON parsing
  QuizModel _parseResponse(Map<String, dynamic> response) {
    try {
      final generatedText = response[0]['generated_text'] ?? '';
      final jsonString = generatedText.replaceAll('\n', '').trim();

      // Handle code formatting responses
      final cleanJson =
          jsonString.replaceAll('```json', '').replaceAll('```', '').trim();

      final jsonData = jsonDecode(cleanJson) as Map<String, dynamic>;

      return QuizModel(
        id: const Uuid().v4(),
        question: jsonData['question']?.toString() ?? 'No question generated',
        options: List<String>.from(jsonData['options'] ?? []),
        correctOptionIndex: jsonData['correctOptionIndex'] as int? ?? 0,
        explanation: jsonData['explanation']?.toString() ?? '',
      );
    } catch (e) {
      print('Raw API response: ${response.toString()}');
      throw Exception('JSON Parse Error: $e');
    }
  }
}
