import '../entities/quiz_question.dart';

abstract class QuizRepository {
  Future<List<QuizQuestion>> getQuizQuestions({required String difficulty});
}
