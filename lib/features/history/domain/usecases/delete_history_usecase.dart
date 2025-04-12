// features/history/domain/usecases/delete_history_usecase.dart
import '../repositories/history_repository.dart';

class DeleteHistoryUseCase {
  final HistoryRepository repository;

  DeleteHistoryUseCase({required this.repository});

  Future<void> execute(String historyId) async {
    await repository.deleteHistory(historyId);
  }
}