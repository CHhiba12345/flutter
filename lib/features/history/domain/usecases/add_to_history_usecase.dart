import '../repositories/history_repository.dart';

class AddToHistoryUseCase {
  final HistoryRepository repository;

  AddToHistoryUseCase({required this.repository});

  Future<void> execute({
    required String productId,
    required String actionType, // 'scan' ou 'view'
  }) async {
    final uid = await repository.getCurrentUser();
    if (uid == null) {
      throw Exception('Utilisateur non authentifié');
    }
      if (actionType == 'scan') {
        await repository.recordScan(uid: uid, productId: productId);
      } else {
        await repository.recordView(uid: uid, productId: productId);
      }
    }
  }
