import 'package:auto_route/auto_route.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:eye_volve/features/home/data/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_router.dart';
import '../../../favorites/data/datasources/favorite_datasource.dart';
import '../../../favorites/data/repositories/favorite_repository_impl.dart';
import '../../../favorites/domain/usecases/add_to_favorites.dart';
import '../../../favorites/domain/usecases/get_favorites.dart';
import '../../../favorites/domain/usecases/remove_from_favorites.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart' as fav;
import '../../../favorites/presentation/bloc/favorite_state.dart';
import '../../../history/data/datasources/history_datasource.dart';
import '../../../history/data/repositories/history_repository_impl.dart';
import '../../data/datasources/home_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/scan_product.dart';
import '../../../history/domain/usecases/record_history.dart';
import '../../../favorites/presentation/bloc/favorite_bloc.dart';
import '../../../favorites/domain/usecases/toggle_favorite_usecase.dart';
import '../bloc/home_bloc.dart';
import '../styles/constant.dart';
import '../styles/home_styles.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/product_search_card.dart';
import 'package:eye_volve/features/favorites/presentation/bloc/favorite_event.dart';
import 'package:eye_volve/features/home/presentation/bloc/home_bloc.dart';
import 'package:eye_volve/features/favorites/presentation/bloc/favorite_event.dart' as fav; // Utilisation de alias

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    print("Construction de HomePage...");
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc(
            scanProduct: ScanProduct(HomeRepositoryImpl(homeDataSource: HomeDataSource(jwtToken: ''))),
            recordHistory: RecordHistory(repository: HistoryRepositoryImpl(dataSource: HistoryDataSource(jwtToken: ''))),
            toggleFavorite: ToggleFavoriteUseCase(FavoriteRepositoryImpl(dataSource: FavoriteDataSource(jwtToken: ''))),
          ),
        ),
        BlocProvider(
          create: (context) => FavoriteBloc(
            addToFavorites: AddToFavorites(FavoriteRepositoryImpl(dataSource: FavoriteDataSource(jwtToken: ''))),
            getFavorites: GetFavorites(FavoriteRepositoryImpl(dataSource: FavoriteDataSource(jwtToken: ''))),
            removeFromFavorites: RemoveFromFavorites(FavoriteRepositoryImpl(dataSource: FavoriteDataSource(jwtToken: ''))),
          )..add(LoadFavoritesEvent(uid: 'current_user_uid')), // Charge les favoris au démarrage
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  void _navigateToHistory(BuildContext context) {
    AutoRouter.of(context).push(const HistoryRoute());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppConstants.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: HomeStyles.appTitle(context),
          leading: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return state is ProductDetailState
                  ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.read<HomeBloc>().add(BackToHomeEvent()),
              )
                  : const SizedBox();
            },
          ),
        ),
        body: const SafeArea(
          child: _MainContent(),
        ),
        bottomNavigationBar: HomeBottomNav(
          onHistoryPressed: () => _navigateToHistory(context),
          currentIndex: 0,
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SearchBarAndScan(),
        Expanded(
          child: _ProductDisplay(),
        ),
      ],
    );
  }
}

class _SearchBarAndScan extends StatelessWidget {
  const _SearchBarAndScan();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: HomeStyles.searchInputDecoration(context),
              onChanged: (query) => context.read<HomeBloc>().add(SearchProductsEvent(query: query)),
              style: HomeStyles.searchTextStyle(context),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: HomeStyles.cameraIcon,
            onPressed: () async {
              final barcode = await BarcodeScanner.scan();
              if (barcode.rawContent.isNotEmpty) {
                context.read<HomeBloc>().add(ScanProductEvent(barcode: barcode.rawContent));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ProductDisplay extends StatelessWidget {
  const _ProductDisplay();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductDetailState) {
          return _buildProductDetail(state.product);
        } else if (state is ProductsLoaded) {
          return _buildProductList(state.products, state.favorites);
        } else if (state is ProductError) {
          return Center(child: Text(state.message));
        } else {
          return const ProductSearchCard();
        }
      },
    );
  }

  Widget _buildProductDetail(Product product) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl.isNotEmpty)
              Center(
                child: Image.network(
                  product.imageUrl,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'Name: ${product.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Nutriscore: ${product.nutriscore}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Marque: ${product.brand}'),
            Text('Catégories: ${product.categories.join(', ')}'),
            const SizedBox(height: 10),
            const Text(
              'Ingrédients:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(product.ingredients.join(', ')),
            const SizedBox(height: 10),
            const Text(
              'Allergènes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(product.allergens.isNotEmpty
                ? product.allergens.join(', ')
                : 'Non spécifié'),
            const SizedBox(height: 10),
            Text('Statut Halal: ${product.halalStatus ? 'Oui' : 'Non'}'),
          ],
        ),
      ),
    );
  }


  Widget _buildProductList(List<Product> products, List<Product> favorites) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        Product product = products[index];
        bool isFavorite = favorites.any((favorite) => favorite.code == product.code); // Vérification du favori

        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading: product.imageUrl.isNotEmpty
                ? Image.network(
              product.imageUrl,
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            )
                : const Icon(Icons.image),
            title: Text(product.name),
            subtitle: Text(product.brand),
            trailing: BlocConsumer<FavoriteBloc, FavoriteState>(
              listener: (context, favoriteState) {
                if (favoriteState is FavoriteSuccess) {
                  print("========action done");
                  // Action supplémentaire si nécessaire
                  setState() {
                    isFavorite = !isFavorite;
                    print("================valeur favorite is favorite  $isFavorite ");
                  }
                }
              },
              builder: (context, favoriteState) {
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null, // Le cœur devient rouge si le produit est favori
                  ),
                  onPressed: () {
                    print("========================before");
                    context.read<FavoriteBloc>().add(ToggleFavoriteEvent(

                      uid: 'current_user_uid',
                      productId: product.code,
                      isFavorite: !isFavorite, // Si le produit est déjà un favori, il faut inverser l'état

                    ),

                    );
                    print("========================after");
                  },
                );
              },
            ),
            onTap: () => context.read<HomeBloc>().add(
              ViewProductEvent(product: product, fromSearch: true),
            ),
          ),
        );
      },
    );
  }
}
