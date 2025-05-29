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

  /// Gère l'ajout ou la suppression d'un produit dans les favoris
  Future<void> _handleToggleFavorite(
      ToggleFavoriteEvent event, Emitter<FavoriteState> emit) async {
    final currentState = state;
    List<FavoriteModel> updatedFavorites = [];

    // Mise à jour optimiste de l'UI
    if (currentState is FavoritesLoaded) {
      updatedFavorites = List.from(currentState.favorites);

      if (event.isFavorite) {
        updatedFavorites.add(FavoriteModel(
          id: 'temp_${event.productId}',
          uid: event.uid,
          productId: event.productId,
          productName: '',
          imageUrl: '',
          timestamp: DateTime.now().toIso8601String(),
        ));
      } else {
        updatedFavorites.removeWhere((f) => f.productId == event.productId);
      }

      emit(FavoritesLoaded(updatedFavorites));
    }

    try {
      // Appel API
      if (event.isFavorite) {
        await addToFavorites.execute(uid: event.uid, productId: event.productId);
      } else {
        await removeFromFavorites.execute(uid: event.uid, productId: event.productId);
      }

      // Rechargement depuis le serveur
      final favorites = await getFavorites.execute(event.uid);
      emit(FavoritesLoaded(await favorites));
    } catch (e) {
      // Annulation en cas d'erreur
      if (currentState is FavoritesLoaded) {
        emit(FavoritesLoaded(currentState.favorites));
      }
      emit(FavoriteError(e.toString()));
    }
  }

  /// Récupère les favoris depuis le backend
  ///
  /// Lance une erreur si l'utilisateur n'est pas connecté
  Future<String> getCurrentUserId() async {
    final authService = AuthService();
    final token = await authService.getCurrentUserToken();
    if (token == null) throw Exception("Token JWT non disponible");

    final userId = await authService.getUserIdFromToken(token);
    return userId ?? 'default_user_uid';
  }

  /// Charge tous les favoris de l'utilisateur
  Future<void> _handleLoadFavorites(
      LoadFavoritesEvent event, Emitter<FavoriteState> emit) async {
    emit(FavoriteLoading());

    try {
      final favorites = await getFavorites.execute(event.uid);
      emit(FavoritesLoaded(await favorites));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }
}