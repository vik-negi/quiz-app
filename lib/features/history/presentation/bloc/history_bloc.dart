import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/di/injection.dart';
import '../../../../../../core/services/local_storage_service.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryInitial()) {
    on<FetchHistory>((event, emit) {
      final history = getIt<LocalStorageService>().getQuizHistory();
      emit(HistoryLoaded(history));
    });

    on<ClearHistory>((event, emit) {
      getIt<LocalStorageService>().clearQuizHistory();
      emit(HistoryLoaded([]));
    });
  }
}
