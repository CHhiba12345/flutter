import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/history.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';

class HistoryCard extends StatelessWidget {
  final History history;
  final VoidCallback onDelete;

  const HistoryCard({super.key, required this.history,required this.onDelete,});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(history.timestamp);

    return Card(
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: history.imageUrl,
          width: 50,
          height: 50,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        title: Text(history.productName),// Adaptez selon vos besoins
        subtitle: Text(
          ' ${date.day}/${date.month}/${date.year}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete, // Appel du callback onDelete
        ),
      ),
    );
  }
}