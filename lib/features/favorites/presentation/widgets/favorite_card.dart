import 'package:eye_volve/features/home/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/favorite.dart';
import '../bloc/favorite_bloc.dart';
import '../bloc/favorite_event.dart';

class FavoriteCard extends StatelessWidget {
  final Favorite favorite;

  const FavoriteCard({super.key, required this.favorite});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(favorite.timestamp) ?? DateTime.now();
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Action optionnelle au clic(je ajouter au future )
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildProductImage(favorite.imageUrl),
          title: Text(
            favorite.productName.isNotEmpty ? favorite.productName : 'Produit inconnu',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            formattedDate,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent),
            tooltip: 'Retirer des favoris',
            onPressed: () => _removeFavorite(context),
            splashRadius: 24,
          ),
        ),
      ),
    );
  }

  /// Construit l'image du produit avec gestion du placeholder et erreur
  Widget _buildProductImage(String imageUrl) {
    const double size = 60;

    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image, color: Colors.grey, size: 32),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: Colors.grey[200],
          child: const Icon(Icons.image, color: Colors.grey, size: 32),
        ),
        errorWidget: (context, url, error) => Container(
          width: size,
          height: size,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.redAccent, size: 32),
        ),
      ),
    );
  }

  /// Supprime le produit des favoris via le bloc
  void _removeFavorite(BuildContext context) {
    if (favorite.productId.isEmpty || favorite.productId == 'default_id') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID de produit invalide')),
      );
      return;
    }

    print('Suppression du favori: ${favorite.productId}');
    context.read<FavoriteBloc>().add(
      ToggleFavoriteEvent(
        uid: favorite.uid,
        productId: favorite.productId,
        isFavorite: false,
      ),
    );
  }
}