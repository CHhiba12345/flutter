import 'package:eye_volve/features/home/domain/entities/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/datasources/auth_service.dart';
import '../../domain/usecases/add_to_favorites.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/remove_from_favorites.dart';
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
      print('on call toggelfavorite bloc');
      if (event.isFavorite) {

        await addToFavorites.execute(uid: event.uid, productId: event.productId);
      } else {
        await removeFromFavorites.execute(uid: event.uid, productId: event.productId);
      }
      emit(FavoriteSuccess());
      print('fav succ===bloc');
    } catch (e) {
      emit(FavoriteError(e.toString()));
      print('erreur bloc ');
    }
  }
  Future<String> getCurrentUserId() async {
    final authService = AuthService();
    final token = await authService.getCurrentUserToken();
    if (token == null) {
      throw Exception("Token JWT non disponible");
    }
    final userId = await authService.getUserIdFromToken(token);
    return userId ?? 'default_user_uid';
  }

  Future<void> _handleLoadFavorites(LoadFavoritesEvent event, Emitter<FavoriteState> emit) async {
    emit(FavoriteLoading());
    try {
      final favorites = await getFavorites.execute(event.uid);
      print("$favorites");

      print("this is the list of the favs : $favorites");

      emit(FavoritesLoaded(await favorites)); // Convertir le Future<List<Product>> en List<Product>
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }
}