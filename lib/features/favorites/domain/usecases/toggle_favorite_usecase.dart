import 'package:eye_volve/features/favorites/data/models/favorite_model.dart';
import 'package:eye_volve/features/home/data/models/product_model.dart';
import 'package:eye_volve/features/home/domain/entities/product.dart';

import '../repositories/favorite_repository.dart';

class ToggleFavoriteUseCase {
  final FavoriteRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<void> execute({required String uid, required String productId}) async {
    await repository.toggleFavorite(uid: uid, productId: productId);
  }

  Future<List<FavoriteModel>> getFavorites(String uid) async {
    return repository.getFavorites(uid);
  }
}