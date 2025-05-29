import '../../domain/repositories/history_repository.dart';

/// UseCase pour enregistrer une action d'utilisateur (scan ou consultation)
class RecordHistory {
  final HistoryRepository repository;

  RecordHistory({required this.repository});

  /// Enregistre une action de scan du produit
  Future<void> recordScan({required String productId}) async {
    try {
      final uid = await repository.getCurrentUser();
      if (uid != null) {
        await repository.recordScan(uid: uid, productId: productId);
      } else {
        throw Exception('Utilisateur non authentifié');
      }
    } catch (e) {
      throw Exception('Échec de l\'enregistrement du scan: ${e.toString()}');
    }
  }

  /// Enregistre une vue du produit
  Future<void> recordView({required String productId}) async {
    final uid = await repository.getCurrentUser();
    if (uid != null) {
      await repository.recordView(uid: uid, productId: productId);
    }
  }
}