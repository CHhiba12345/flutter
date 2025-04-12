import '../entities/history.dart';

abstract class HistoryRepository {
  Future<List<History>> getUserHistory(String uid);
  Future<void> recordScan({required String uid, required String productId});
  Future<void> recordView({required String uid, required String productId});
  Future<String?> getCurrentUser(); // Pour obtenir l'UID de l'utilisateur actuel
  Future<void> deleteHistory(String historyId);
}