import '../repositories/favorite_repository.dart';

class RemoveFromFavorites {
  final FavoriteRepository repository;

  RemoveFromFavorites(this.repository);

  Future<void> execute({required String uid, required String productId}) async {
    await repository.toggleFavorite(uid: uid, productId: productId);
  }
}