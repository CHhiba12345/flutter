import 'package:eye_volve/features/favorites/data/models/favorite_model.dart';
import '../../../home/domain/entities/product.dart';

/// Statut global du bloc favoris
enum FavoriteStatus { initial, loading, success, error }

/// Classe abstraite de base pour tous les états du bloc Favoris
abstract class FavoriteState {
  final FavoriteStatus status;
  final String? errorMessage;

  FavoriteState({this.status = FavoriteStatus.initial, this.errorMessage});
}

/// État initial — Aucune donnée chargée
class FavoriteInitial extends FavoriteState {
  FavoriteInitial() : super(status: FavoriteStatus.initial);
}

/// Liste des favoris chargée avec succès
class FavoritesLoaded extends FavoriteState {
  final List<FavoriteModel> favorites;

  FavoritesLoaded(this.favorites, {FavoriteStatus status = FavoriteStatus.success})
      : super(status: status);
}

/// Erreur lors de l'interaction avec les favoris
class FavoriteError extends FavoriteState {
  FavoriteError(String message)
      : super(status: FavoriteStatus.error, errorMessage: message);
}

/// Chargement en cours
class FavoriteLoading extends FavoriteState {
  FavoriteLoading() : super(status: FavoriteStatus.loading);
}

/// Opération réussie (ajout/suppression)
class FavoriteSuccess extends FavoriteState {
  FavoriteSuccess() : super(status: FavoriteStatus.success);
}