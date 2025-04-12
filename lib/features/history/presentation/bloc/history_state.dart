import '../../domain/entities/history.dart';

abstract class HistoryState {
  const HistoryState();
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<History> histories;

  const HistoryLoaded(this.histories);
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);
}
class HistoryDeleting extends HistoryState {
  const HistoryDeleting();
}