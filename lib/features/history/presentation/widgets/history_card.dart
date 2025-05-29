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
          // Action optionnelle au clic sur la carte
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          leading: _buildProductImage(context),
          title: Text(
            history.productName.isNotEmpty ? history.productName : 'Produit inconnu',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            formattedDate,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Supprimer',
            onPressed: () => _confirmDelete(context),
          ),
        ),
      ),
    );
  }

  /// Affiche l'image du produit avec gestion du placeholder et erreur
  Widget _buildProductImage(BuildContext context) {
    if (history.imageUrl.isEmpty || !history.imageUrl.startsWith('http')) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    return CachedNetworkImage(
      imageUrl: history.imageUrl,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: 60,
        height: 60,
        color: Colors.grey[200],
        child: const Icon(Icons.image, color: Colors.grey),
      ),
      errorWidget: (context, url, error) => Container(
        width: 60,
        height: 60,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.redAccent),
      ),
    );
  }

  /// Demande de confirmation avant suppression
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Voulez-vous vraiment supprimer cette entrée ?"),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }
}