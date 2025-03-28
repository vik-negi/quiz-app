import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveScore(int score, String difficulty) async {
    final scores = _prefs.getStringList('scores_$difficulty') ?? [];
    scores.add('$score:${DateTime.now().toIso8601String()}');
    await _prefs.setStringList('scores_$difficulty', scores);
  }

  Future<void> clearQuizHistory() async {
    await _prefs.remove('quiz_history');
  }

  List<Map<String, dynamic>> getPastScores(String difficulty) {
    final scores = _prefs.getStringList('scores_$difficulty') ?? [];
    return scores.map((entry) {
      final parts = entry.split(':');
      return {'score': int.parse(parts[0]), 'date': parts.sublist(1).join(':')};
    }).toList();
  }

  Future<void> saveQuizHistory(String question, List<String> options,
      String correctAnswer, String userAnswer) async {
    final history = _prefs.getStringList('quiz_history') ?? [];
    final entry = jsonEncode({
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'timestamp': DateTime.now().toIso8601String(),
    });
    history.add(entry);
    await _prefs.setStringList('quiz_history', history);
  }

  List<Map<String, dynamic>> getQuizHistory() {
    final history = _prefs.getStringList('quiz_history') ?? [];
    return history
        .map((entry) => jsonDecode(entry) as Map<String, dynamic>)
        .toList();
  }
}
