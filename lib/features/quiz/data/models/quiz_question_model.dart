import '../../domain/entities/quiz_question.dart';

class QuizQuestionModel {
  final String question;
  final List<String> options;
  final String correct;

  QuizQuestionModel({
    required this.question,
    required this.options,
    required this.correct,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      question: json['question'],
      options: List<String>.from(json['options']),
      correct: json['correct'],
    );
  }

  QuizQuestion toEntity() => QuizQuestion(
        question: question,
        options: options,
        correctAnswer: correct,
      );
}
