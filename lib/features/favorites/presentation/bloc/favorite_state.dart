

import '../../domain/entities/favorite.dart';

abstract class FavoriteState {}

class FavoritesLoaded extends FavoriteState {
  final List<Favorite> favorites;
  FavoritesLoaded(this.favorites);

}
