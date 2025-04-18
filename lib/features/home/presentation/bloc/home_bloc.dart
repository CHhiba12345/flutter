import 'package:eye_volve/features/favorites/data/models/favorite_model.dart';
import 'package:eye_volve/features/home/data/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eye_volve/features/home/domain/entities/product.dart';
import 'package:rxdart/rxdart.dart';
import '../../../auth/data/datasources/auth_service.dart';
import '../../../favorites/domain/usecases/toggle_favorite_usecase.dart';
import '../../../history/domain/usecases/record_history.dart';
import '../../domain/usecases/scan_product.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ScanProduct scanProduct;
  final RecordHistory recordHistory;
  final ToggleFavoriteUseCase toggleFavorite;

  HomeBloc({required this.scanProduct, required this.recordHistory, required this.toggleFavorite})
      : super(HomeInitial()) {
    on<SearchProductsEvent>(
      _onSearchProduct,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<ScanProductEvent>(_onScanProduct);
    on<ResetSearchEvent>(_onResetSearch);
    on<ViewProductEvent>(_onViewProduct);
    on<ShowProductDetailEvent>(_onShowProductDetail);
    on<BackToHomeEvent>(_onBackToHome);
    on<HomeToggleFavoriteEvent>(_onToggleFavorite); // Renommé ici
  }

  // 🔥 Utilitaire pour debounce les événements de recherche
  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  /////////////
  Future<void> _onToggleFavorite(HomeToggleFavoriteEvent event, Emitter<HomeState> emit) async {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final updatedFavorites = currentState.favorites.toList();
      final isFavorite = updatedFavorites.contains(event.productId);

      // Toggle dans la liste locale
      if (isFavorite) {
        updatedFavorites.remove(event.productId);
      } else {
        updatedFavorites.add(event.productId as FavoriteModel);
      }

      try {
        // Appel au backend pour mettre à jour les favoris avec le bon UID
        await toggleFavorite.execute(uid: 'current_user_uid', productId: event.productId);

        // Mettre à jour l'état local
        emit(ProductsLoaded(products: currentState.products, favorites: updatedFavorites));
      } catch (e) {
        emit(ProductError(message: "Erreur lors de la mise à jour des favoris: $e"));
      }
    }
  }

  Future<void> _onScanProduct(ScanProductEvent event, Emitter<HomeState> emit) async {
    emit(ProductLoading());
    try {
      final product = await scanProduct.execute(event.barcode);
      if (product.code.isEmpty) {
        emit(ProductError(message: "Produit invalide"));
      } else {
        await recordHistory.recordScan(productId: product.code);
        emit(ProductDetailState(product: product));
      }
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onViewProduct(ViewProductEvent event, Emitter<HomeState> emit) async {
    try {
      if (event.fromSearch) {
        await recordHistory.recordView(productId: event.product.code);
      }
      emit(ProductDetailState(product: event.product));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onSearchProduct(SearchProductsEvent event, Emitter<HomeState> emit) async {
    if (event.query.isEmpty) {
      emit(HomeInitial());
      return;
    }

    emit(ProductLoading());
    try {
      // Recherche des produits
      final products = await scanProduct.search(event.query);

      // Récupération des favoris de l'utilisateur avec le bon UID
      final favorites = await toggleFavorite.getFavorites('current_user_uid');

      // Émission de l'état avec les produits et les favoris
      emit(ProductsLoaded(products: products, favorites: favorites));
    } catch (e) {
      emit(ProductError(message: "Erreur lors de la recherche de produits: $e"));
    }
  }

  void _onResetSearch(ResetSearchEvent event, Emitter<HomeState> emit) {
    emit(HomeInitial());
  }

  void _onShowProductDetail(ShowProductDetailEvent event, Emitter<HomeState> emit) {
    emit(ProductDetailState(product: event.product));
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

  void _onBackToHome(BackToHomeEvent event, Emitter<HomeState> emit) {
    emit(HomeInitial());
  }
}