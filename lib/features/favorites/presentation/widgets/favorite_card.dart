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
        leading: CachedNetworkImage(
          imageUrl: favorite.imageUrl,
          width: 50,
          height: 50,
          placeholder: (context, url) =>
              Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image),
              ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        title: Text(favorite.productName.isNotEmpty
            ? favorite.productName
            : 'Produit inconnu'),
        subtitle: Text(formattedDate),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            context.read<FavoriteBloc>().add(ToggleFavoriteEvent(
              uid: favorite.uid,
              productId: favorite.productId,
              isFavorite: false,
            ));
          },
        ),
      ),
    );
  }
}