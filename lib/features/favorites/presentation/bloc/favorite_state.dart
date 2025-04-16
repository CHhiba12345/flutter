import 'package:eye_volve/features/favorites/data/models/favorite_model.dart';

import '../../../home/domain/entities/product.dart';

enum FavoriteStatus { initial, loading, success, error }

abstract class FavoriteState {
  final FavoriteStatus status;
  final String? errorMessage;

  FavoriteState({this.status = FavoriteStatus.initial, this.errorMessage});
}

class FavoriteInitial extends FavoriteState {
  FavoriteInitial() : super(status: FavoriteStatus.initial);
}

class FavoritesLoaded extends FavoriteState {
  final List<FavoriteModel> favorites;

  FavoritesLoaded(this.favorites, {FavoriteStatus status = FavoriteStatus.initial})
      : super(status: status);
}

class FavoriteError extends FavoriteState {
  FavoriteError(String message) : super(status: FavoriteStatus.error, errorMessage: message);
}

class FavoriteLoading extends FavoriteState {
  FavoriteLoading() : super(status: FavoriteStatus.loading);
}

class FavoriteSuccess extends FavoriteState {
  FavoriteSuccess() : super(status: FavoriteStatus.success);
}
