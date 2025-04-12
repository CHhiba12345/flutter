import '../../domain/repositories/history_repository.dart';

class RecordHistory {
  final HistoryRepository repository;

  RecordHistory({required this.repository});

  Future<void> recordScan({required String productId}) async {
    try {
      final uid = await repository.getCurrentUser();
      if (uid != null) {
        await repository.recordScan(uid: uid, productId: productId);
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      throw Exception('Failed to record scan: ${e.toString()}');
    }
  }

  Future<void> recordView({required String productId}) async {
    final uid = await repository.getCurrentUser();
    if (uid != null) {
      await repository.recordView(uid: uid, productId: productId);
    }
  }
}