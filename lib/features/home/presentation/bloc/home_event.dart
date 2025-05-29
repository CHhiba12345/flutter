// Déclaration que ce fichier fait partie du home_bloc.dart
part of 'home_bloc.dart';

// Classe abstraite de base pour tous les événements du HomeBloc
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

// Événement pour scanner un produit via son code-barres
class ScanProductEvent extends HomeEvent {
  final String barcode;
  const ScanProductEvent({required this.barcode});
  @override
  List<Object> get props => [barcode];
}

// Événement pour rechercher des produits par requête textuelle
class SearchProductsEvent extends HomeEvent {
  final String query;
  const SearchProductsEvent({required this.query});
  @override
  List<Object> get props => [query];
}

// Événement pour réinitialiser la recherche
class ResetSearchEvent extends HomeEvent {}

// Événement pour visualiser un produit spécifique
class ViewProductEvent extends HomeEvent {
  final Product product;
  final bool fromSearch;
  const ViewProductEvent({required this.product, this.fromSearch = false});
  @override
  List<Object> get props => [product, fromSearch];
}

// Événement pour afficher les détails d'un produit
class ShowProductDetailEvent extends HomeEvent {
  final Product product;
  const ShowProductDetailEvent({required this.product});
  @override
  List<Object> get props => [product];
}

// Événement pour revenir à l'écran d'accueil
class BackToHomeEvent extends HomeEvent {}

// Événement pour basculer l'état favori d'un produit
class HomeToggleFavoriteEvent extends HomeEvent {
  final String uid;
  final String productId;

  const HomeToggleFavoriteEvent({required this.uid, required this.productId});

  @override
  List<Object> get props => [uid, productId];
}