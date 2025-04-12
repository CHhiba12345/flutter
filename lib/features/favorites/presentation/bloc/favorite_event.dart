

abstract class FavoriteEvent {}

class ToggleFavoriteEvent extends FavoriteEvent {
  final String uid;
  final String productId;

  ToggleFavoriteEvent({required this.uid, required this.productId});
}

class LoadFavoritesEvent extends FavoriteEvent {
  final String uid;

  LoadFavoritesEvent({required this.uid});
}