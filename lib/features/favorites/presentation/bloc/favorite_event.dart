abstract class FavoriteEvent {}

class ToggleFavoriteEvent extends FavoriteEvent {
  final String uid;
  final String productId;
  final bool isFavorite; // This is used to toggle the favorite status

  ToggleFavoriteEvent({
    required this.uid,
    required this.productId,
    required this.isFavorite,
  });
}

class LoadFavoritesEvent extends FavoriteEvent {
  final String uid;

  LoadFavoritesEvent({required this.uid});
}