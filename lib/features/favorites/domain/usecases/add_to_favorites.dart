import '../repositories/favorite_repository.dart';

class AddToFavorites {
  final FavoriteRepository repository;

  AddToFavorites(this.repository);

  Future<void> execute({required String uid, required String productId}) async {
    await repository.toggleFavorite(uid: uid, productId: productId);
  }
}