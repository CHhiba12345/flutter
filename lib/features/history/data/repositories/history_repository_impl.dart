import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/history.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_datasource.dart';
import '../models/history_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDataSource dataSource;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  HistoryRepositoryImpl({required this.dataSource});

  @override
  Future<List<History>> getUserHistory(String uid) async {
    final models = await dataSource.getUserHistory(uid);
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<void> recordScan({required String uid, required String productId}) async {
    final currentUserUid = await getCurrentUser();
    if (currentUserUid == null) {
      throw Exception('Utilisateur non authentifié');
    }

    await dataSource.recordAction(
      uid: currentUserUid,
      productId: productId,
      actionType: 'scan',
    );
  }

  @override
  Future<void> recordView({required String uid, required String productId}) async {
    await dataSource.recordAction(
      uid: uid,
      productId: productId,
      actionType: 'view',
    );
  }

  @override
  Future<String?> getCurrentUser() async {
    return _firebaseAuth.currentUser?.uid;
  }

  @override
  Future<void> deleteHistory(String historyId) async {
    await dataSource.deleteHistory(historyId);
  }

  /// Convertit un [HistoryModel] en entité [History]
  History _mapModelToEntity(HistoryModel model) {
    if (model.id == null) {
      throw Exception('ID manquant dans l\'historique');
    }

    return History(
      id: model.id!,
      uid: model.uid,
      productName: model.productName,
      imageUrl: model.imageUrl,
      productId: model.productId,
      actionType: model.actionType,
      timestamp: model.timestamp,
    );
  }
}