import 'package:equatable/equatable.dart';
import '../../domain/entities/quiz_question.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final List<String?> userAnswers;
  final int score;
  final int timerSeconds;
  final String difficulty;
  final bool? isLastAnswerCorrect;

  const QuizLoaded({
    required this.questions,
    this.currentIndex = 0,
    required this.userAnswers,
    this.score = 0,
    this.timerSeconds = 30,
    required this.difficulty,
    this.isLastAnswerCorrect,
  });

  QuizLoaded copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    List<String?>? userAnswers,
    int? score,
    int? timerSeconds,
    String? difficulty,
    bool? isLastAnswerCorrect,
  }) {
    return QuizLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      score: score ?? this.score,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      difficulty: difficulty ?? this.difficulty,
      isLastAnswerCorrect: isLastAnswerCorrect ?? this.isLastAnswerCorrect,
    );
  }

  @override
  List<Object> get props => [
        questions,
        currentIndex,
        userAnswers,
        score,
        timerSeconds,
        difficulty,
        isLastAnswerCorrect ?? false,
      ];
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object> get props => [message];
}
