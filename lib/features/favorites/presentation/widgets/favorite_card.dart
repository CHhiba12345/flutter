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
      child: ListTile(
        leading: _buildProductImage(favorite.imageUrl),
        title: Text(favorite.productName),
        subtitle: Text(formattedDate),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => _removeFavorite(context),
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return Container(
        width: 50,
        height: 50,
        color: Colors.grey[200],
        child: const Icon(Icons.image),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Image(image: imageProvider),
      placeholder: (context, url) => const Icon(Icons.image),
      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
    );

  }

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