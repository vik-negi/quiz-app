abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<Map<String, dynamic>> history;

  HistoryLoaded(this.history);
}
