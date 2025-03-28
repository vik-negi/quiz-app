import '../models/quiz_question_model.dart';
import '../services/groq_service.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/repositories/quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  final GroqService groqService;

  QuizRepositoryImpl(this.groqService);

  @override
  Future<List<QuizQuestion>> getQuizQuestions({required String difficulty}) async {
    try {
      final jsonQuestions = await groqService.fetchQuizQuestions(difficulty: difficulty);
      return jsonQuestions.map((json) => QuizQuestionModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw Exception('Error fetching quiz questions: $e');
    }
  }
}
