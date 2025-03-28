import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_quiz_questions.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';
import '../../../../core/services/local_storage_service.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GetQuizQuestions getQuizQuestions;
  final LocalStorageService localStorageService;
  Timer? _timer;

  QuizBloc(this.getQuizQuestions, this.localStorageService)
      : super(QuizInitial()) {
    on<FetchQuizQuestions>(_onFetchQuizQuestions);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<ResetQuiz>(_onResetQuiz);
    on<TimerTick>(_onTimerTick);
  }

  Future<void> _onFetchQuizQuestions(
      FetchQuizQuestions event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      final questions = await getQuizQuestions(difficulty: event.difficulty);
      emit(QuizLoaded(
        questions: questions,
        userAnswers: List.filled(questions.length, null),
        difficulty: event.difficulty,
      ));
      _startTimer(emit);
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  void _onAnswerQuestion(AnswerQuestion event, Emitter<QuizState> emit) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final question = currentState.questions[event.questionIndex];
      final isCorrect = question.correctAnswer == event.selectedAnswer;
      final newUserAnswers = List<String?>.from(currentState.userAnswers)
        ..[event.questionIndex] = event.selectedAnswer;
      final newScore = isCorrect ? currentState.score + 1 : currentState.score;

      localStorageService.saveQuizHistory(
        question.question,
        question.options,
        question.correctAnswer,
        event.selectedAnswer,
      );

      _timer?.cancel();
      emit(currentState.copyWith(
        userAnswers: newUserAnswers,
        currentIndex: currentState.currentIndex + 1,
        score: newScore,
        timerSeconds: 30,
        isLastAnswerCorrect: isCorrect,
      ));
      if (currentState.currentIndex + 1 < currentState.questions.length) {
        _startTimer(emit);
      } else {
        localStorageService.saveScore(newScore, currentState.difficulty);
      }
    }
  }

  void _onResetQuiz(ResetQuiz event, Emitter<QuizState> emit) {
    _timer?.cancel();
    emit(QuizInitial());
  }

  void _onTimerTick(TimerTick event, Emitter<QuizState> emit) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      if (event.remainingSeconds > 0) {
        emit(currentState.copyWith(timerSeconds: event.remainingSeconds));
      } else {
        _timer?.cancel();
        emit(currentState.copyWith(
          currentIndex: currentState.currentIndex + 1,
          timerSeconds: 30,
          isLastAnswerCorrect: null,
        ));
        if (currentState.currentIndex + 1 < currentState.questions.length) {
          _startTimer(emit);
        } else {
          localStorageService.saveScore(
              currentState.score, currentState.difficulty);
        }
      }
    }
  }

  void _startTimer(Emitter<QuizState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is QuizLoaded) {
        final currentState = state as QuizLoaded;
        add(TimerTick(currentState.timerSeconds - 1));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
