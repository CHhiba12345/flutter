import '../entities/history.dart';
import '../repositories/history_repository.dart';

class GetHistoryUseCase {
  final HistoryRepository repository;

  GetHistoryUseCase({required this.repository});

  Future<List<History>> execute() async {
    final uid = await repository.getCurrentUser();
    if (uid == null) return [];
    return repository.getUserHistory(uid);
  }
}