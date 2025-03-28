import 'package:equatable/equatable.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object> get props => [];
}

class FetchQuizQuestions extends QuizEvent {
  final String difficulty;

  const FetchQuizQuestions(this.difficulty);

  @override
  List<Object> get props => [difficulty];
}

class AnswerQuestion extends QuizEvent {
  final int questionIndex;
  final String selectedAnswer;

  const AnswerQuestion(this.questionIndex, this.selectedAnswer);

  @override
  List<Object> get props => [questionIndex, selectedAnswer];
}

class ResetQuiz extends QuizEvent {}

class TimerTick extends QuizEvent {
  final int remainingSeconds;

  const TimerTick(this.remainingSeconds);

  @override
  List<Object> get props => [remainingSeconds];
}
