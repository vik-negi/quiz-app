import '../entities/quiz_question.dart';
import '../repositories/quiz_repository.dart';

class GetQuizQuestions {
  final QuizRepository repository;

  GetQuizQuestions(this.repository);

  Future<List<QuizQuestion>> call({required String difficulty}) async {
    return await repository.getQuizQuestions(difficulty: difficulty);
  }
}
