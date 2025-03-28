import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GroqService {
  static String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  static const String apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  Future<List<dynamic>> fetchQuizQuestions({required String difficulty}) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192',
          'messages': [
            {
              'role': 'user',
              'content':
                  'Generate 5 random multiple-choice questions on general knowledge with $difficulty difficulty. Each should have a question, 4 options, and the correct answer clearly marked as "correct". Return only valid JSON only. Do not include any other text or explanation. The JSON should be an array of objects, each containing the question, options, and correct.',
            }
          ],
        }),
      );

      debugPrint('Response status: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final contentString = data['choices'][0]['message']['content'];
        final jsonStart = contentString.indexOf('[');
        final jsonEnd = contentString.lastIndexOf(']') + 1;
        final jsonContent = contentString.substring(jsonStart, jsonEnd);
        final jsonList = jsonDecode(jsonContent);
        return jsonList;
      } else {
        throw Exception('Failed to fetch quiz questions');
      }
    } catch (e) {
      log('Error fetching quiz questions: $e');
      rethrow;
    }
  }
}
