import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eye_volve/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:eye_volve/features/home/domain/entities/product.dart';
import 'package:lottie/lottie.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart';
import '../../../favorites/presentation/bloc/favorite_state.dart';
import '../styles/constant.dart';
import '../styles/th.dart' show AppTheme;
import '../../../auth/data/datasources/auth_service.dart';

class ProductSearchCard extends StatelessWidget {
  final Product? product;

  const ProductSearchCard({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppConstants.symmetricPadding,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: product != null ? _buildProductInfo(context, product!) : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Padding(
      padding: AppConstants.defaultPadding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 320,
              height: 220,
              child: Lottie.asset('assets/animations/search.json'),
            ),
            const SizedBox(height: 24),
            const Text(
              'No product selected',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan or search for a product to see\nnutritional information here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context, Product product) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favoriteState) {
        bool isFavorite = false;
        if (favoriteState is FavoritesLoaded) {
          isFavorite = favoriteState.favorites.any((fav) => fav.productId == product.code);
        } else if (favoriteState is FavoriteLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (favoriteState is FavoriteError) {
          return Center(child: Text(favoriteState.errorMessage ?? 'Error loading favorites'));
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () async {
                          final authService = AuthService();
                          final userId = await authService.getCurrentUserToken();
                          final uid = await authService.getUserIdFromToken(userId ?? '');
                          context.read<FavoriteBloc>().add(
                            ToggleFavoriteEvent(
                              uid: uid ?? 'default_user_uid',
                              productId: product.code,
                              isFavorite: !isFavorite,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (product.brand != null) _buildInfoRow('Brand', product.brand!),
                  if (product.nutriscore != null) _buildInfoRow('Nutriscore', product.nutriscore!.toUpperCase()),
                  _buildInfoRow('Halal', product.halalStatus == true ? "Yes" : "No"),
                  const SizedBox(height: 10),
                  _buildInfoRow('Code', product.code),

                  // Ingredients
                  if (product.ingredients?.text != null) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow('Ingredients', product.ingredients!.text!),
                  ],

                  // Categories
                  if (product.categories != null) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow('Categories', product.categories!),
                  ],

                  // Allergens
                  if (product.ingredients?.allergens?.isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    _buildInfoList('Allergens', product.ingredients!.allergens!),
                  ],

                  // Nutrition facts
                  if (product.nutrition?.facts != null) ...[
                    const SizedBox(height: 10),
                    _buildSectionTitle('Nutrition Facts'),
                    if (product.nutrition!.facts!.energyKcal != null)
                      _buildInfoRow('Energy', '${product.nutrition!.facts!.energyKcal} kcal'),
                    if (product.nutrition!.facts!.fat != null)
                      _buildInfoRow('Fat', '${product.nutrition!.facts!.fat} g'),
                    if (product.nutrition!.facts!.carbohydrates != null)
                      _buildInfoRow('Carbs', '${product.nutrition!.facts!.carbohydrates} g'),
                    if (product.nutrition!.facts!.proteins != null)
                      _buildInfoRow('Proteins', '${product.nutrition!.facts!.proteins} g'),
                    if (product.nutrition!.facts!.salt != null)
                      _buildInfoRow('Salt', '${product.nutrition!.facts!.salt} g'),
                  ],

                  // Nova group
                  if (product.processing?.novaGroup != null) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow('NOVA Group', '${product.processing!.novaGroup}'),
                  ],

                  // Ecoscore
                  if (product.environment?.ecoscore != null) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow('Ecoscore', product.environment!.ecoscore!.toUpperCase()),
                  ],

                  // Image
                  if (product.imageUrl?.isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    _buildImageSection(product.imageUrl!),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildInfoList(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(items.join(', ')),
        ],
      ),
    );
  }

  Widget _buildImageSection(String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product Image:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Center(
          child: Image.network(
            imageUrl,
            width: 150,
            height: 150,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 50),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: 150,
                height: 150,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}