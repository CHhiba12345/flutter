import 'package:auto_route/auto_route.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
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
                              icon: const Icon(Icons.history, color: Colors.white, size: 30),
                              onPressed: () {
                                debugPrint("Navigating to History Page");
                                AutoRouter.of(context).push(const HistoryRoute());
                              },
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
    super.initState();
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
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is AllergensLoaded || state is AllergensUpdated) {
              final allergens = state is AllergensLoaded
                  ? state.allergens
                  : (state as AllergensUpdated).allergens;
              setState(() {
                userAllergens = allergens;
              });
            }
          },
        ),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return _buildLoadingShimmer();
          } else if (state is ProductDetailState) {
            return _buildProductDetail(state.product);
          } else if (state is ProductsLoaded) {
            return _buildProductList(state.products);
          } else if (state is ProductError) {
            return Center(child: Text(state.message));
          } else {
            return const ProductSearchCard();
          }
        },
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }


  Widget _buildProductDetail(Product product) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favoriteState) {
        bool isFavorite = false;
        if (favoriteState is FavoritesLoaded) {
          isFavorite = favoriteState.favorites
              .any((fav) => fav.productId == product.code);
        }

        bool hasAllergenAlert = false;
        String? alertMessage;

        if (userAllergens.isNotEmpty && product.ingredients?.allergens != null) {
          final productAllergens = product.ingredients!.allergens!
              .map((a) => a.toLowerCase())
              .toList();

          final matchingAllergens = userAllergens
              .where((userAllergen) =>
              productAllergens.contains(userAllergen.toLowerCase()))
              .toList();

          if (matchingAllergens.isNotEmpty) {
            hasAllergenAlert = true;
            alertMessage =
            'Warning! This product contains allergens that may affect you: ${matchingAllergens.join(', ')}';
          }
        }

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product name and brand
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  product.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.2,
                                  ),
                                ),
                                if (product.brand != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Brand: ${product.brand!}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Product image with shadow and better border radius
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 220,
                                    width: double.infinity,
                                    color: Colors.grey.shade100,
                                    child: product.imageUrl?.isNotEmpty == true
                                        ? Image.network(
                                      product.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                      const Center(
                                        child: Icon(Icons.image_not_supported,
                                            size: 60, color: Colors.grey),
                                      ),
                                    )
                                        : const Center(
                                      child: Icon(Icons.image,
                                          size: 60, color: Colors.grey),
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite ? Colors.red : Colors.grey,
                                          size: 28,
                                        ),
                                        onPressed: () async {
                                          final authService = AuthService();
                                          final token = await authService
                                              .getCurrentUserToken();
                                          if (token != null) {
                                            final userId = await authService
                                                .getUserIdFromToken(token);
                                            if (userId != null) {
                                              context.read<FavoriteBloc>().add(
                                                ToggleFavoriteEvent(
                                                  uid: userId,
                                                  productId: product.code,
                                                  isFavorite: !isFavorite,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Allergen alert with improved design
                          if (hasAllergenAlert)
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      size: 28, color: Colors.red.shade700),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      alertMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Nutriscore and Ecoscore badges with better spacing
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Augmenté de 1 à 8
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final badgeWidth = (constraints.maxWidth - 16) / 2 - 8; // Calcul dynamique
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (product.nutriscore != null)
                                      Flexible( // Utilisation de Flexible au lieu de Expanded
                                        child: SizedBox(
                                          width: badgeWidth, // Largeur calculée dynamiquement
                                          child: _ScoreBadge(
                                            label: 'NUTRI-SCORE',
                                            value: product.nutriscore!.toUpperCase(),
                                            color: _getNutriscoreColor(product.nutriscore!),
                                          ),
                                        ),
                                      ),
                                    if (product.environment?.ecoscore != null)
                                      Flexible(
                                        child: SizedBox(
                                          width: badgeWidth,
                                          child: _ScoreBadge(
                                            label: 'ECO-SCORE',
                                            value: product.environment!.ecoscore!.toUpperCase(),
                                            color: _getEcoscoreColor(product.environment!.ecoscore!),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Product details sections with improved cards
                          _buildDetailSection(
                            title: 'Information',
                            icon: Icons.info_outline,
                            children: [
                              _buildDetailItem(
                                'Categories',
                                product.categories ?? 'Not specified',
                                icon: Icons.category,
                              ),
                              _buildDetailItem(
                                'Halal status',
                                product.halalStatus == true ? '✅ Yes' : '❌ No',
                                icon: Icons.verified_user,
                              ),
                              if (product.processing?.novaGroup != null)
                                _buildDetailItem(
                                  'Level of processing',
                                  'NOVA ${product.processing!.novaGroup}',
                                  icon: Icons.transform,
                                ),
                            ],
                          ),

                          if (product.ingredients?.text != null)
                            _buildDetailSection(
                              title: 'Ingredients',
                              icon: Icons.list_alt_outlined,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    product.ingredients!.text!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          if (product.ingredients?.allergens?.isNotEmpty == true)
                            _buildDetailSection(
                              title: 'Allergens',
                              icon: Icons.warning_amber_outlined,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: product.ingredients!.allergens!
                                      .map((allergen) => Chip(
                                    label: Text(
                                      allergen,
                                      style: TextStyle(
                                        color: userAllergens.contains(
                                            allergen.toLowerCase())
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    backgroundColor: userAllergens.contains(
                                        allergen.toLowerCase())
                                        ? Colors.red.shade400
                                        : Colors.grey.shade200,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ))
                                      .toList(),
                                ),
                              ],
                            ),

                          if (product.nutrition?.facts != null)
                            _buildDetailSection(
                              title: 'Nutrition facts',
                              icon: Icons.abc_outlined,
                              children: [
                                _NutritionFactsTable(facts: product.nutrition!.facts!),
                              ],
                            ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bouton de retour positionné en absolu dans le Stack
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 12,
                child: SafeArea(
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.7),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.black,
                          size: 24),
                      onPressed: () {
                        context.read<HomeBloc>().add(BackToHomeEvent());
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Ajoutez ces méthodes si elles n'existent pas déjà
  Widget _buildDetailItem(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(icon, size: 20, color: Colors.grey.shade600),
            ),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.lightGreen.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: Colors.white, size: 15),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [Color(0xBBF6E5E8), Color(0xFFC8E6C9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children.map((child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: child,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }




  Widget _buildProductList(List<Product> products) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favoriteState) {
        final favoriteIds = favoriteState is FavoritesLoaded
            ? favoriteState.favorites.map((f) => f.productId).toSet()
            : <String>{};

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            final isFavorite = favoriteIds.contains(product.code);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: product.imageUrl?.isNotEmpty == true
                      ? Image.network(
                    product.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )
                      : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.brand != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          product.brand!,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ),
                    if (product.nutriscore != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getNutriscoreColor(product.nutriscore!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Nutri-Score: ${product.nutriscore!.toUpperCase()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    final authService = AuthService();
                    final token = await authService.getCurrentUserToken();
                    final userId = token != null ? await authService.getUserIdFromToken(token) : null;
                    if (userId != null) {
                      context.read<FavoriteBloc>().add(
                        ToggleFavoriteEvent(
                          uid: userId,
                          productId: product.code,
                          isFavorite: !isFavorite,
                        ),
                      );
                    }
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



  Color _getNutriscoreColor(String score) {
    switch (score.toLowerCase()) {
      case 'a': return Colors.green.shade600;
      case 'b': return Colors.lightGreen.shade400;
      case 'c': return Colors.yellow.shade600;
      case 'd': return Colors.orange.shade600;
      case 'e': return Colors.red.shade600;
      default: return Colors.grey;
    }
  }

  Color _getEcoscoreColor(String score) {
    switch (score.toLowerCase()) {
      case 'a': return Colors.green.shade600;
      case 'b': return Colors.lightGreen.shade400;
      case 'c': return Colors.yellow.shade600;
      case 'd': return Colors.orange.shade600;
      case 'e': return Colors.red.shade600;
      default: return Colors.grey.shade600;
    }
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionFactsTable extends StatelessWidget {
  final NutritionFacts facts;

  const _NutritionFactsTable({required this.facts});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2), // Colonne gauche : nom du nutriment
          1: FlexColumnWidth(1), // Colonne droite : valeur
        },
        border: TableBorder.symmetric(
          inside: BorderSide(
            color: Colors.white,
            width: 0.8,
          ),
        ),
        children: [
          _buildTableRow('Energy', '${facts.energyKcal} kcal'),
          _buildTableRow('Fat', '${facts.fat} g'),
          _buildTableRow('of which saturated fat', '${facts.fat} g'),
          _buildTableRow('Carbohydrates', '${facts.carbohydrates} g'),
          _buildTableRow('of which sugars', '${facts.fat} g'),
          _buildTableRow('Dietary fiber', '${facts.fat} g'),
          _buildTableRow('Proteins', '${facts.proteins} g'),
          _buildTableRow('Salt', '${facts.salt} g'),
        ],

      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}