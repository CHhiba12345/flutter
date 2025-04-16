part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class ProductLoading extends HomeState {}

class ProductsLoaded extends HomeState {
  final List<Product> products;
  final List<FavoriteModel> favorites;
  const ProductsLoaded({required this.products, required this.favorites});
  @override
  List<Object> get props => [products, favorites];
}

class ProductDetailState extends HomeState {
  final Product product;
  const ProductDetailState({required this.product});
  @override
  List<Object> get props => [product];
}

class ProductError extends HomeState {
  final String message;
  const ProductError({required this.message});
  @override
  List<Object> get props => [message];
}