part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

class ScanProductEvent extends HomeEvent {
  final String barcode;
  const ScanProductEvent({required this.barcode});
  @override
  List<Object> get props => [barcode];
}

class SearchProductsEvent extends HomeEvent {
  final String query;
  const SearchProductsEvent({required this.query});
  @override
  List<Object> get props => [query];
}

class ResetSearchEvent extends HomeEvent {}

class ViewProductEvent extends HomeEvent {
  final Product product;
  final bool fromSearch;
  const ViewProductEvent({required this.product, this.fromSearch = false});
  @override
  List<Object> get props => [product, fromSearch];
}

class ShowProductDetailEvent extends HomeEvent {
  final Product product;
  const ShowProductDetailEvent({required this.product});
  @override
  List<Object> get props => [product];
}

class BackToHomeEvent extends HomeEvent {}
class ToggleFavoriteEvent extends HomeEvent {
  final String uid;
  final Product productId;

  const ToggleFavoriteEvent({required this.uid, required this.productId});

  @override
  List<Object> get props => [uid, productId];
}