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

  // Variables pour conserver l'état précédent
  String? _lastSearchQuery;
  List<Product> _cachedProducts = [];
  List<FavoriteModel> _cachedFavorites = [];

  HomeBloc({
    required this.scanProduct,
    required this.recordHistory,
    required this.toggleFavorite,
  }) : super(HomeInitial()) {
    on<SearchProductsEvent>(
      _onSearchProduct,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<ScanProductEvent>(_onScanProduct);
    on<ResetSearchEvent>(_onResetSearch);
    on<ViewProductEvent>(_onViewProduct);
    on<ShowProductDetailEvent>(_onShowProductDetail);
    on<BackToHomeEvent>(_onBackToHome);
    on<HomeToggleFavoriteEvent>(_onToggleFavorite);
  }

  // Utilitaire pour debounce les événements de recherche
  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  Future<void> _onSearchProduct(SearchProductsEvent event, Emitter<HomeState> emit) async {
    if (event.query.isEmpty) {
      emit(HomeInitial());
      return;
    }
    emit(ProductLoading());
    try {
      _lastSearchQuery = event.query; // Conserver la dernière requête
      final products = await scanProduct.search(event.query);
      final userId = await getCurrentUserId();
      final favorites = await toggleFavorite.getFavorites(userId);
      _cachedProducts = products; // Mettre en cache les produits
      _cachedFavorites = favorites; // Mettre en cache les favoris
      emit(ProductsLoaded(products: products, favorites: favorites));
    } catch (e) {
      emit(ProductError(message: "Erreur lors de la recherche: $e"));
    }
  }

  Future<void> _onScanProduct(ScanProductEvent event, Emitter<HomeState> emit) async {
    emit(ProductLoading());
    try {
      final product = await scanProduct.execute(event.barcode);
      if (product.code.isEmpty) {
        emit(ProductNotFoundState(barcode: event.barcode)); // Nouvel état pour produit non trouvé
      } else {
        await recordHistory.recordScan(productId: product.code);
        emit(ProductDetailState(product: product));
      }
    } catch (e) {
      emit(ProductNotFoundState(barcode: event.barcode)); // Utilisez le même état pour les erreurs
    }
  }

  Future<void> _onViewProduct(ViewProductEvent event, Emitter<HomeState> emit) async {
    try {
      // Record the view action first
      if (event.fromSearch) {
        await recordHistory.recordView(productId: event.product.code);
      }

      // Then emit the product detail state
      emit(ProductDetailState(product: event.product));

      // If we're coming from a search, reload the history
      if (event.fromSearch) {
        // You might want to add an event to reload history here if needed
      }
    } catch (e) {
      emit(ProductError(message: e.toString()));
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

  Future<void> _onBackToHome(BackToHomeEvent event, Emitter<HomeState> emit) async {
    if (_cachedProducts.isNotEmpty && _cachedFavorites.isNotEmpty) {
      // Recharger les favoris au cas où ils auraient changé
      final userId = await getCurrentUserId();
      final favorites = await toggleFavorite.getFavorites(userId);
      emit(ProductsLoaded(products: _cachedProducts, favorites: favorites));
    } else if (_lastSearchQuery != null) {
      // Relancer la dernière recherche
      add(SearchProductsEvent(query: _lastSearchQuery!));
    } else {
      emit(HomeInitial());
    }
  }

  Future<void> _onToggleFavorite(HomeToggleFavoriteEvent event, Emitter<HomeState> emit) async {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final updatedFavorites = currentState.favorites.toList();
      final isFavorite = updatedFavorites.any((fav) => fav.productId == event.productId);

      // Toggle dans la liste locale
      if (isFavorite) {
        updatedFavorites.removeWhere((fav) => fav.productId == event.productId);
      } else {
        updatedFavorites.add(FavoriteModel(
          id: '',
          uid: '',
          productId: event.productId,
          productName: '',
          imageUrl: '',
          timestamp: '',
        ));
      }

      try {
        // Appel au backend pour mettre à jour les favoris
        await toggleFavorite.execute(uid: 'current_user_uid', productId: event.productId);
        emit(ProductsLoaded(products: currentState.products, favorites: updatedFavorites));
      } catch (e) {
        emit(ProductError(message: "Erreur lors de la mise à jour des favoris: $e"));
      }
    }
  }
}