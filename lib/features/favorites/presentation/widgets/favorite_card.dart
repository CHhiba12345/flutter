import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/favorite.dart';

class FavoriteCard extends StatelessWidget {
  final Favorite favorite;

  const FavoriteCard({super.key, required this.favorite});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(favorite.timestamp);
    return Card(
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: favorite.imageUrl,
          width: 50,
          height: 50,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        title: Text(favorite.productName),
        subtitle: Text('${date.day}/${date.month}/${date.year}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // Trigger suppression ici
          },
        ),
      ),
    );
  }
}