import 'package:auto_route/auto_route.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../app_router.dart';
import '../../../auth/data/datasources/auth_service.dart';
import '../../../favorites/data/datasources/favorite_datasource.dart';
import '../../../favorites/data/models/favorite_model.dart';
import '../../../favorites/data/repositories/favorite_repository_impl.dart';
import '../../../favorites/domain/usecases/add_to_favorites.dart';
import '../../../favorites/domain/usecases/get_favorites.dart';
import '../../../favorites/domain/usecases/remove_from_favorites.dart';
import '../../../favorites/presentation/bloc/favorite_bloc.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart';
import '../../../favorites/presentation/bloc/favorite_state.dart';
import '../../../history/data/datasources/history_datasource.dart';
import '../../../history/data/repositories/history_repository_impl.dart';
import '../../../history/domain/usecases/delete_history_usecase.dart';
import '../../../history/domain/usecases/get_history_usecase.dart';
import '../../../history/presentation/bloc/history_bloc.dart';
import '../../../history/presentation/bloc/history_event.dart';
import '../../../profile/data/datasources/profile_datasource.dart';
import '../../../profile/data/repositories/profile_repository_impl.dart';
import '../../../profile/domain/usecases/clear_user_allergens.dart';
import '../../../profile/domain/usecases/get_user_allergens.dart';
import '../../../profile/domain/usecases/set_user_allergens.dart';
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
import '../../../profile/presentation/bloc/profile_bloc.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc(
            scanProduct: ScanProduct(HomeRepositoryImpl(homeDataSource: HomeDataSource())),
            recordHistory: RecordHistory(repository: HistoryRepositoryImpl(dataSource: HistoryDataSource())),
            toggleFavorite: ToggleFavoriteUseCase(FavoriteRepositoryImpl(dataSource: FavoriteDataSource())),
          ),
        ),
        BlocProvider(
          create: (context) => FavoriteBloc(
            addToFavorites: AddToFavorites(FavoriteRepositoryImpl(dataSource: FavoriteDataSource())),
            getFavorites: GetFavorites(FavoriteRepositoryImpl(dataSource: FavoriteDataSource())),
            removeFromFavorites: RemoveFromFavorites(FavoriteRepositoryImpl(dataSource: FavoriteDataSource())),
          )..add(LoadFavoritesEvent(uid: 'current_user_uid')),
        ),

        BlocProvider(
          create: (context) => HistoryBloc(
            getHistoryUseCase: GetHistoryUseCase(repository: HistoryRepositoryImpl(dataSource: HistoryDataSource())),
            recordHistory: RecordHistory(repository: HistoryRepositoryImpl(dataSource: HistoryDataSource())),
            deleteHistory: DeleteHistoryUseCase(repository: HistoryRepositoryImpl(dataSource: HistoryDataSource())),
          )..add(LoadHistoryEvent()),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(
            getUserAllergens: GetUserAllergens(ProfileRepositoryImpl(
              dataSource: ProfileDataSourceImpl(
                client: http.Client(),
                authService: AuthService(),
              ),
            )),
            setUserAllergens: SetUserAllergens(ProfileRepositoryImpl(
              dataSource: ProfileDataSourceImpl(
                client: http.Client(),
                authService: AuthService(),
              ),
            )),
            clearUserAllergens: ClearUserAllergens(ProfileRepositoryImpl(
              dataSource: ProfileDataSourceImpl(
                client: http.Client(),
                authService: AuthService(),
              ),
            )),
            authService: AuthService(),
          ),
        ),
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
    // Charger les allergènes dès que la page est affichée
      context.read<ProfileBloc>().add(InitializeAllergens());

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
          // Background gradient
          Container(
            height: statusBarHeight + 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3E6839), Color(0xFF83BC6D)],
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
                              icon: const Icon(Icons.notifications, color: Colors.white, size: 30),
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
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: const Text(
                                  '3',
                                  style: TextStyle(color: Colors.white, fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_outlined, color: Colors.white, size: 30),
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
              onChanged: (query) => context.read<HomeBloc>().add(SearchProductsEvent(query: query)),
              style: HomeStyles.searchTextStyle(context),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: HomeStyles.cameraIcon,
            onPressed: () async {
              try {
                final barcode = await BarcodeScanner.scan();
                if (barcode.rawContent.isNotEmpty) {
                  context.read<HomeBloc>().add(ScanProductEvent(barcode: barcode.rawContent));
                }
              } on PlatformException catch (e) {
                if (e.code == BarcodeScanner.cameraAccessDenied) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera permission denied')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.message}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
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
  List<String> userAllergens = [];

  @override
  void initState() {
    super.didChangeDependencies();
    _loadUserAllergens();
  }
  Future<void> _loadUserAllergens() async {
    final authService = AuthService();
    final token = await authService.getCurrentUserToken();
    if (token != null) {
      final userId = await authService.getUserIdFromToken(token);
      if (userId != null) {
        context.read<ProfileBloc>().add(InitializeAllergens());
      }
    }
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
    return MultiBlocListener(
      listeners: [
        BlocListener<FavoriteBloc, FavoriteState>(
          listener: (context, state) {
            if (state is FavoriteSuccess) {
              setState(() {});
            }
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is AllergensLoaded || state is AllergensUpdated ) {
              final allergens = state is AllergensLoaded
                  ? state.allergens
                  : (state as AllergensUpdated).allergens;

              if (mounted) {
                setState(() {
                  userAllergens = allergens;
                  debugPrint('✅ Allergènes mis à jour dans HomePage: $userAllergens');
                });
              }
            }
          },
        )
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
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
      ),
    );
  }

  Widget _buildProductDetail(Product product) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favoriteState) {
        bool isFavorite = false;
        if (favoriteState is FavoritesLoaded) {
          isFavorite = favoriteState.favorites.any((fav) => fav.productId == product.code);
        }

        // Vérifier si le produit contient des allergènes de l'utilisateur
        bool hasAllergenAlert = false;
        String? alertMessage;

        if (userAllergens.isNotEmpty && product.ingredients?.allergens != null) {
          final productAllergens = product.ingredients!.allergens!
              .map((a) => a.toLowerCase())
              .toList();

          final matchingAllergens = userAllergens
              .where((userAllergen) => productAllergens.contains(userAllergen.toLowerCase()))
              .toList();

          if (matchingAllergens.isNotEmpty) {
            hasAllergenAlert = true;
            alertMessage = ' Be careful! This product may contain your allergens 😯: ${matchingAllergens.join(', ')}';
          }

          debugPrint('🔍 Allergènes de l\'utilisateur: $userAllergens');
          debugPrint('🔍 Allergènes du produit: $productAllergens');
          debugPrint('🔍 Allergènes correspondants: $matchingAllergens');
        }


        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                onPressed: () {
                  context.read<HomeBloc>().add(BackToHomeEvent());
                },
              ),
            ),
            title: Text(
              'Détails',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            toolbarHeight: 30,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: product.imageUrl?.isNotEmpty == true
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                      ),
                    )
                        : const Center(child: Icon(Icons.image, size: 50)),
                  ),
                  // Product name and favorite button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 28,
                        ),
                        onPressed: () async {
                          final userId = await getCurrentUserId();
                          context.read<FavoriteBloc>().add(
                            ToggleFavoriteEvent(
                              uid: userId,
                              productId: product.code,
                              isFavorite: !isFavorite,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  // Allergen Alert
                  if (hasAllergenAlert)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              alertMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Basic info
                  _buildInfoCard(
                    children: [
                      if (product.nutriscore != null) _buildInfoRow('Nutriscore', product.nutriscore!.toUpperCase()),
                      if (product.brand != null) _buildInfoRow('Marque', product.brand!),
                      if (product.categories != null) _buildInfoRow('Catégories', product.categories!),
                      _buildInfoRow('Statut Halal', product.halalStatus == true ? 'Oui' : 'Non'),
                    ],
                  ),
                  // Ingredients
                  if (product.ingredients?.text != null) ...[
                    _buildSectionTitle('Ingrédients'),
                    _buildInfoCard(
                      children: [
                        Text(
                          product.ingredients!.text!,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                  // Allergens
                  if (product.ingredients?.allergens?.isNotEmpty == true) ...[
                    _buildSectionTitle('Allergènes'),
                    _buildInfoCard(
                      children: [
                        Text(
                          product.ingredients!.allergens!.join(', '),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                  // Nutrition facts
                  if (product.nutrition?.facts != null) ...[
                    _buildSectionTitle('Valeurs nutritionnelles'),
                    _buildInfoCard(
                      children: [
                        if (product.nutrition!.facts!.energyKcal != null)
                          _buildInfoRow('Énergie', '${product.nutrition!.facts!.energyKcal} kcal'),
                        if (product.nutrition!.facts!.fat != null)
                          _buildInfoRow('Matières grasses', '${product.nutrition!.facts!.fat} g'),
                        if (product.nutrition!.facts!.carbohydrates != null)
                          _buildInfoRow('Glucides', '${product.nutrition!.facts!.carbohydrates} g'),
                        if (product.nutrition!.facts!.proteins != null)
                          _buildInfoRow('Protéines', '${product.nutrition!.facts!.proteins} g'),
                        if (product.nutrition!.facts!.salt != null)
                          _buildInfoRow('Sel', '${product.nutrition!.facts!.salt} g'),
                      ],
                    ),
                  ],
                  // Nova group
                  if (product.processing?.novaGroup != null) ...[
                    _buildSectionTitle('Niveau de transformation'),
                    _buildInfoCard(
                      children: [
                        _buildInfoRow('NOVA', 'Groupe ${product.processing!.novaGroup}'),
                      ],
                    ),
                  ],
                  // Ecoscore
                  if (product.environment?.ecoscore != null) ...[
                    _buildSectionTitle('Impact environnemental'),
                    _buildInfoCard(
                      children: [
                        _buildInfoRow('Ecoscore', product.environment!.ecoscore!.toUpperCase()),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products, List<FavoriteModel> favorites) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favoriteState) {
        final favoriteIds = favoriteState is FavoritesLoaded
            ? favoriteState.favorites.map((f) => f.productId).toSet()
            : <String>{};
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final isFavorite = favoriteIds.contains(product.code);
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: product.imageUrl?.isNotEmpty == true
                    ? Image.network(
                  product.imageUrl!,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                )
                    : const Icon(Icons.image),
                title: Text(product.name),
                subtitle: Text(product.brand ?? ''),
                trailing: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () async {
                    final userId = await getCurrentUserId();
                    context.read<FavoriteBloc>().add(
                      ToggleFavoriteEvent(
                        uid: userId,
                        productId: product.code,
                        isFavorite: !isFavorite,
                      ),
                    );
                  },
                ),
                onTap: () {
                  context.read<HomeBloc>().add(
                    ViewProductEvent(product: product, fromSearch: true),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}