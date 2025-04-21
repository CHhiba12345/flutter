import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eye_volve/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:eye_volve/features/home/domain/entities/product.dart';
import 'package:lottie/lottie.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart';
import '../../../favorites/presentation/bloc/favorite_state.dart';
import '../styles/constant.dart';
import '../styles/th.dart' show AppTheme;

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
              child: Lottie.asset('assets/animations/search.json'), // Assure-toi que le fichier est bien ajouté dans assets
            ),
            const SizedBox(height: 24),
            const Text(
              'No product selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan or search for a product to see\nnutritional information here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context, Product product) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favoriteState) {
        final isFavorite = favoriteState is FavoritesLoaded &&
            favoriteState.favorites.any((fav) => fav.productId == product.code);  // Correction ici : fav.productId -> fav.code

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
                        onPressed: () {
                          context.read<FavoriteBloc>().add(
                            ToggleFavoriteEvent(
                              uid: 'current_user_uid',  // Remplacez par l'UID réel de l'utilisateur
                              productId: product.code,  // Utilisation de product.code comme identifiant
                              isFavorite: !isFavorite,  // L'état du favori (inverse l'état actuel)
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  _buildInfoRow('Brand', product.brand),
                  _buildInfoRow('Nutriscore', product.nutriscore),
                  _buildInfoRow('Halal', product.halalStatus ? "Yes" : "No"),
                  const SizedBox(height: 10),
                  _buildInfoRow('Code', product.code),
                  const SizedBox(height: 10),
                  _buildInfoList('Ingredients', product.ingredients),
                  const SizedBox(height: 10),
                  _buildInfoList('Categories', product.categories),
                  const SizedBox(height: 10),
                  _buildInfoList('Allergens', product.allergens),
                  const SizedBox(height: 10),
                  _buildImageSection(product.imageUrl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title : ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value?.toString() ?? 'Not available'),
          ),
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
          Text('$title : ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(items.join(', ')),
        ],
      ),
    );
  }

  Widget _buildImageSection(String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Image:', style: TextStyle(fontWeight: FontWeight.bold)),
        if (imageUrl.isNotEmpty)
          Image.network(
            imageUrl,
            width: 100,
            height: 100,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
          )
        else
          const Text('No image available'),
      ],
    );
  }
}
