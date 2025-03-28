import 'package:get_it/get_it.dart';
import '../services/local_storage_service.dart';
import '../../features/quiz/data/repositories/quiz_repository_impl.dart';
import '../../features/quiz/data/services/groq_service.dart';
import '../../features/quiz/domain/usecases/get_quiz_questions.dart';
import '../../features/quiz/presentation/bloc/quiz_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  getIt.registerSingleton<LocalStorageService>(localStorageService);
  getIt.registerLazySingleton(() => GroqService());
  getIt.registerLazySingleton(() => QuizRepositoryImpl(getIt<GroqService>()));
  getIt.registerLazySingleton(
      () => GetQuizQuestions(getIt<QuizRepositoryImpl>()));
  getIt.registerFactory(() => QuizBloc(
        getIt<GetQuizQuestions>(),
        getIt<LocalStorageService>(),
      ));
}
