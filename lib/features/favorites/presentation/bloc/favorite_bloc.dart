import 'package:eye_volve/features/favorites/domain/entities/favorite.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_to_favorites.dart';
import '../../domain/usecases/remove_from_favorites.dart';
import '../../domain/usecases/get_favorites.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';


class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final AddToFavorites addToFavorites;
  final RemoveFromFavorites removeFromFavorites;
  final GetFavorites getFavorites;

  FavoriteBloc({
    required this.addToFavorites,
    required this.removeFromFavorites,
    required this.getFavorites,
  }) : super(FavoriteInitial()) {
    on<ToggleFavoriteEvent>(_handleToggleFavorite);
    on<LoadFavoritesEvent>(_handleLoadFavorites);
  }

  Future<void> _handleToggleFavorite(ToggleFavoriteEvent event, Emitter<FavoriteState> emit) async {
    emit(FavoriteLoading());
    try {
      await addToFavorites.execute(uid: event.uid, productId: event.productId);
      emit(FavoriteSuccess());
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _handleLoadFavorites(LoadFavoritesEvent event, Emitter<FavoriteState> emit) async {
    emit(FavoriteLoading());
    try {
      final favorites = await getFavorites.execute(event.uid);
      emit(FavoritesLoaded(favorites as List<Favorite>));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }
}