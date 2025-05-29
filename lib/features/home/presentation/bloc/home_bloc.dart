import 'package:eye_volve/features/favorites/data/models/favorite_model.dart';
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

// Bloc principal pour la gestion de l'état de l'écran d'accueil
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // UseCases nécessaires pour les opérations métier
  final ScanProduct scanProduct;
  final RecordHistory recordHistory;
  final ToggleFavoriteUseCase toggleFavorite;

  // Variables d'état pour la gestion du cache
  String? _lastSearchQuery;
  List<Product> _cachedProducts = [];
  List<FavoriteModel> _cachedFavorites = [];

  // Constructeur initialisant les UseCases et les gestionnaires d'événements
  HomeBloc({
    required this.scanProduct,
    required this.recordHistory,
    required this.toggleFavorite,
  }) : super(HomeInitial()) {
    // Configuration des gestionnaires d'événements
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

  // Méthode utilitaire pour debouncer les événements (anti-rebond)
  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  // Gestionnaire pour l'événement de recherche de produits
  Future<void> _onSearchProduct(SearchProductsEvent event, Emitter<HomeState> emit) async {
    if (event.query.isEmpty) {
      emit(HomeInitial());
      return;
    }
    emit(ProductLoading());
    try {
      _lastSearchQuery = event.query; // Sauvegarde de la dernière requête
      final products = await scanProduct.search(event.query);
      final userId = await getCurrentUserId();
      final favorites = await toggleFavorite.getFavorites(userId);
      _cachedProducts = products; // Mise en cache des produits
      _cachedFavorites = favorites; // Mise en cache des favoris
      emit(ProductsLoaded(products: products, favorites: favorites));
    } catch (e) {
      emit(ProductError(message: "Erreur lors de la recherche: $e"));
    }
  }

  // Gestionnaire pour l'événement de scan de produit
  Future<void> _onScanProduct(ScanProductEvent event, Emitter<HomeState> emit) async {
    emit(ProductLoading());
    try {
      final product = await scanProduct.execute(event.barcode);
      if (product.code.isEmpty) {
        emit(ProductNotFoundState(barcode: event.barcode));
      } else {
        await recordHistory.recordScan(productId: product.code);
        emit(ProductDetailState(product: product));
      }
    } catch (e) {
      emit(ProductNotFoundState(barcode: event.barcode));
    }
  }

  // Gestionnaire pour l'événement de visualisation de produit
  Future<void> _onViewProduct(ViewProductEvent event, Emitter<HomeState> emit) async {
    try {
      // Enregistrement de la visualisation dans l'historique
      if (event.fromSearch) {
        await recordHistory.recordView(productId: event.product.code);
      }

      // Affichage des détails du produit
      emit(ProductDetailState(product: event.product));

      // Rechargement de l'historique si nécessaire
      if (event.fromSearch) {
        // Potentiel rechargement de l'historique
      }
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  // Gestionnaire pour réinitialiser la recherche
  void _onResetSearch(ResetSearchEvent event, Emitter<HomeState> emit) {
    emit(HomeInitial());
  }

  // Gestionnaire pour afficher les détails d'un produit
  void _onShowProductDetail(ShowProductDetailEvent event, Emitter<HomeState> emit) {
    emit(ProductDetailState(product: event.product));
  }

  // Méthode utilitaire pour obtenir l'ID de l'utilisateur courant
  Future<String> getCurrentUserId() async {
    final authService = AuthService();
    final token = await authService.getCurrentUserToken();
    if (token == null) {
      throw Exception("Token JWT non disponible");
    }
    final userId = await authService.getUserIdFromToken(token);
    return userId ?? 'default_user_uid';
  }

  // Gestionnaire pour revenir à l'écran d'accueil
  Future<void> _onBackToHome(BackToHomeEvent event, Emitter<HomeState> emit) async {
    if (_cachedProducts.isNotEmpty && _cachedFavorites.isNotEmpty) {
      // Rechargement des favoris
      final userId = await getCurrentUserId();
      final favorites = await toggleFavorite.getFavorites(userId);
      emit(ProductsLoaded(products: _cachedProducts, favorites: favorites));
    } else if (_lastSearchQuery != null) {
      // Relance de la dernière recherche
      add(SearchProductsEvent(query: _lastSearchQuery!));
    } else {
      emit(HomeInitial());
    }
  }

  // Gestionnaire pour basculer un produit en favori
  Future<void> _onToggleFavorite(HomeToggleFavoriteEvent event, Emitter<HomeState> emit) async {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final updatedFavorites = currentState.favorites.toList();
      final isFavorite = updatedFavorites.any((fav) => fav.productId == event.productId);

      // Mise à jour locale de l'état des favoris
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
        // Mise à jour des favoris dans le backend
        await toggleFavorite.execute(uid: 'current_user_uid', productId: event.productId);
        emit(ProductsLoaded(products: currentState.products, favorites: updatedFavorites));
      } catch (e) {
        emit(ProductError(message: "Erreur lors de la mise à jour des favoris: $e"));
      }
    }
  }
}