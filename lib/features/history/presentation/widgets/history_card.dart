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
    final date = DateTime.tryParse(history.timestamp);
    final formattedDate = date != null
        ? '${date.day}/${date.month}/${date.year}'
        : 'Date inconnue';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Ajouter une action si nécessaire au clic sur la carte
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: history.imageUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: history.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 60,
                height: 30,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              errorWidget: (context, url, error) =>
                  Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, color: Colors.redAccent),
                  ),
            )
                : Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          title: Text(
            history.productName.isNotEmpty ? history.productName : 'Produit inconnu',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            formattedDate,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Supprimer',
            onPressed: () async {
              try {
                onDelete();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Entrée supprimée avec succès')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la suppression : $e')),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

}