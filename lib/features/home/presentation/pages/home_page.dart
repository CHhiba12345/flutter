import 'package:auto_route/auto_route.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_router.dart';
import '../../../auth/data/datasources/auth_service.dart';
import '../../../favorites/data/datasources/favorite_datasource.dart';
import '../../../favorites/data/repositories/favorite_repository_impl.dart';
import '../../../favorites/domain/usecases/add_to_favorites.dart';
import '../../../favorites/domain/usecases/get_favorites.dart';
import '../../../favorites/domain/usecases/remove_from_favorites.dart';
import '../../../favorites/presentation/bloc/favorite_bloc.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart';
import '../../../favorites/presentation/bloc/favorite_state.dart';
import '../../../history/data/datasources/history_datasource.dart';
import '../../../history/data/repositories/history_repository_impl.dart';
import '../../data/datasources/home_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/scan_product.dart';
import '../../../history/domain/usecases/record_history.dart';
import '../../../favorites/domain/usecases/toggle_favorite_usecase.dart';
import '../bloc/home_bloc.dart';
import '../styles/constant.dart';
import '../styles/home_styles.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/product_search_card.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
        BlocProvider(
        create: (context) => HomeBloc(
      scanProduct: ScanProduct(HomeRepositoryImpl(
          homeDataSource: HomeDataSource(jwtToken: ''))),
      recordHistory: RecordHistory(
          repository: HistoryRepositoryImpl(
              dataSource: HistoryDataSource(jwtToken: ''))),
      toggleFavorite: ToggleFavoriteUseCase(FavoriteRepositoryImpl(
          dataSource: FavoriteDataSource(jwtToken: ''))),
    ),
    ),
    BlocProvider(
    create: (context) => FavoriteBloc(
    addToFavorites: AddToFavorites(FavoriteRepositoryImpl(
    dataSource: FavoriteDataSource(jwtToken: ''))),
    getFavorites: GetFavorites(FavoriteRepositoryImpl(
    dataSource: FavoriteDataSource(jwtToken: ''))),
    removeFromFavorites: RemoveFromFavorites(FavoriteRepositoryImpl(
    dataSource: FavoriteDataSource(jwtToken: ''))),
    )..add(LoadFavoritesEvent(uid: 'current_user_uid')),
    )
    ],

    child: const _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
          // Background gradient
          Container(
            height: statusBarHeight + 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF13729A),
                  Color(0xFF7FD3F8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          Column(
            children: [
              SizedBox(height: statusBarHeight),
              // Custom AppBar
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Center(
                        child: HomeStyles.appTitle(context),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications,
                                  color: Colors.white, size: 30),
                              onPressed: () {},
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                constraints: const BoxConstraints(
                                    minWidth: 16, minHeight: 16),
                                child: const Text(
                                  '3',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_outlined,
                              color: Colors.white, size: 30),
                          onPressed: () {
                            AutoRouter.of(context).push(const FavoritesRoute());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Main content
              const Expanded(
                child: SafeArea(
                  top: false,
                  child: _MainContent(),
                ),
              ),
            ],
          ),
        ],
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
              onChanged: (query) =>
                  context.read<HomeBloc>().add(SearchProductsEvent(query: query)),
              style: HomeStyles.searchTextStyle(context),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: HomeStyles.cameraIcon,
            onPressed: () async {
              final barcode = await BarcodeScanner.scan();
              if (barcode.rawContent.isNotEmpty) {
                context
                    .read<HomeBloc>()
                    .add(ScanProductEvent(barcode: barcode.rawContent));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ProductDisplay extends StatefulWidget {
  const _ProductDisplay();

  @override
  State<_ProductDisplay> createState() => _ProductDisplayState();
}

class _ProductDisplayState extends State<_ProductDisplay> {
  List<String> favorites = [];

  bool isFavoriteProduct(String productId) {
    return favorites.contains(productId);
  }

  void toggleFavorite(String productId) {
    setState(() {
      if (favorites.contains(productId)) {
        favorites.remove(productId);
      } else {
        favorites.add(productId);
      }
    });
  }

  Future<String> getCurrentUserId() async {
    final authService = AuthService();
    final token = await authService.getCurrentUserToken();
    if (token == null) return 'default_user_uid';
    final userId = await authService.getUserIdFromToken(token);
    return userId ?? 'default_user_uid';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductDetailState) {
          return _buildProductDetail(state.product);
        } else if (state is ProductsLoaded) {
          if (favorites.isEmpty && state.favorites.isNotEmpty) {
            favorites = state.favorites.map((product) => product.productId).toList();
          }
          return _buildProductList(state.products, state.favorites.cast<Product>());
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

  Widget _buildProductList(List<Product> products, List<Product> initialFavorites) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        Product product = products[index];
        bool isFavorite = favorites.contains(product.code);
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading: product.imageUrl.isNotEmpty
                ? Image.network(
              product.imageUrl,
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error),
            )
                : const Icon(Icons.image),
            title: Text(product.name),
            subtitle: Text(product.brand),
            trailing: BlocConsumer<FavoriteBloc, FavoriteState>(
              listener: (context, favoriteState) {
                if (favoriteState is FavoriteSuccess) {
                  toggleFavorite(product.code);
                }
              },
              builder: (context, favoriteState) {
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () async {
                    final userId = await getCurrentUserId();
                    context.read<FavoriteBloc>().add(ToggleFavoriteEvent(
                      uid: userId,
                      productId: product.code,
                      isFavorite: !isFavorite,
                    ));
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