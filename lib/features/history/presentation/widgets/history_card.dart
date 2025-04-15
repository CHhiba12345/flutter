import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/history.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';

class HistoryCard extends StatelessWidget {
  final History history;
  final VoidCallback onDelete;

  const HistoryCard({
    super.key,
    required this.history,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(history.timestamp); // Utiliser tryParse pour éviter les exceptions
    final formattedDate = date != null
        ? '${date.day}/${date.month}/${date.year}'
        : 'Date inconnue'; // Fournir une valeur par défaut

    return Card(
      child: ListTile(
        leading: history.imageUrl.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: history.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.image),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        )
            : const Icon(Icons.image),
        title: Text(
          history.productName.isNotEmpty ? history.productName : 'Produit inconnu',
        ),
        subtitle: Text(formattedDate),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            try {
              onDelete(); // Appel du callback onDelete
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entrée supprimée avec succès')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur lors de la suppression : $e')),
              );
            }
          },
        ),
      ),
    );
  }
}