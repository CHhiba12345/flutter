// Fait partie du fichier principal home_bloc.dart
part of 'home_bloc.dart';

// Classe abstraite de base pour tous les états du HomeBloc
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

// État initial lorsque l'écran d'accueil est chargé
class HomeInitial extends HomeState {}

// État indiquant que les produits sont en cours de chargement
class ProductLoading extends HomeState {}

// État contenant la liste des produits chargés et les favoris
class ProductsLoaded extends HomeState {
  final List<Product> products;
  final List<FavoriteModel> favorites;

  const ProductsLoaded({
    required this.products,
    required this.favorites
  });

  @override
  List<Object> get props => [products, favorites];
}

// État affichant les détails d'un produit spécifique
class ProductDetailState extends HomeState {
  final Product product;
  const ProductDetailState({required this.product});
  @override
  List<Object> get props => [product];
}

// État d'erreur avec un message d'erreur
class ProductError extends HomeState {
  final String message;
  const ProductError({required this.message});
  @override
  List<Object> get props => [message];
}

// État lorsque le produit n'a pas été trouvé
class ProductNotFoundState extends HomeState {
  final String barcode;

  const ProductNotFoundState({required this.barcode});

  @override
  List<Object> get props => [barcode];
}