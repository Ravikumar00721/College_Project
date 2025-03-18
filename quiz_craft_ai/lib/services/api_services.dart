import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  final String baseUrl =
      'https://api.huggingface.co/models/deepseek-ai/deepseek-r1';
  final String apiKey =
      'YOUR_HUGGINGFACE_API_KEY'; // Replace with your actual API key

  Future<Map<String, dynamic>> fetchResponse(String inputText) async {
    final uri = Uri.parse('$baseUrl');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({"inputs": inputText});

    final response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch response: ${response.statusCode}');
    }
  }
}
