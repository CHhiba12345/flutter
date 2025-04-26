import 'package:eye_volve/features/home/domain/entities/product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/datasources/auth_service.dart';
import '../../data/models/favorite_model.dart';
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
    // État actuel
    final currentState = state;
    List<FavoriteModel> updatedFavorites = [];

    print("[ToggleFavorite] Event reçu : isFavorite=${event.isFavorite}, uid=${event.uid}, productId=${event.productId}");

    if (currentState is FavoritesLoaded) {
      // Copie des favoris actuels
      updatedFavorites = List.from(currentState.favorites);

      // Mise à jour optimiste
      if (event.isFavorite) {
        print("[ToggleFavorite] Ajout optimiste du favori");
        updatedFavorites.add(FavoriteModel(
          id: 'temp_${event.productId}',
          uid: event.uid,
          productId: event.productId,
          productName: '',
          imageUrl: '',
          timestamp: DateTime.now().toIso8601String(),
        ));
      } else {
        print("[ToggleFavorite] Suppression optimiste du favori");
        updatedFavorites.removeWhere((f) => f.productId == event.productId);
      }

      emit(FavoritesLoaded(updatedFavorites));
    }

    try {
      if (event.isFavorite) {
        print("[ToggleFavorite] Appel serveur pour ajouter au favori");
        await addToFavorites.execute(uid: event.uid, productId: event.productId);
      } else {
        print("[ToggleFavorite] Appel serveur pour SUPPRIMER des favoris");
        await removeFromFavorites.execute(uid: event.uid, productId: event.productId);
      }

      print("[ToggleFavorite] Rechargement des favoris depuis le serveur...");
      final favorites = await getFavorites.execute(event.uid);

      print("[ToggleFavorite] Favoris rechargés: $favorites");

      emit(FavoritesLoaded(await favorites));
    } catch (e) {
      print("[ToggleFavorite] ERREUR : $e");

      if (currentState is FavoritesLoaded) {
        emit(FavoritesLoaded(currentState.favorites));
      }
      emit(FavoriteError(e.toString()));
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