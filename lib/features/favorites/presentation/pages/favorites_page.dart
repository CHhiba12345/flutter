import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../auth/data/datasources/auth_service.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../domain/usecases/add_to_favorites.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/remove_from_favorites.dart';
import '../bloc/favorite_bloc.dart';
import '../bloc/favorite_event.dart';
import '../bloc/favorite_state.dart';
import '../widgets/favorite_card.dart';
@RoutePage()
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService().getCurrentUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Erreur lors de la récupération de l\'UID'));
        } else {
          final uid = snapshot.data!;
          return _FavoritesContent(uid: uid);
        }
      },
    );
  }
}

class _FavoritesContent extends StatelessWidget {
  final String uid;

  const _FavoritesContent({required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      FavoriteBloc(
        addToFavorites: AddToFavorites(context.read<FavoriteRepository>()),
        removeFromFavorites: RemoveFromFavorites(
            context.read<FavoriteRepository>()),
        getFavorites: GetFavorites(context.read<FavoriteRepository>()),
      )
        ..add(LoadFavoritesEvent(uid: uid)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mes Favoris')),
        body: BlocBuilder<FavoriteBloc, FavoriteState>(
          builder: (context, state) {
            if (state is FavoriteLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FavoritesLoaded) {
              return ListView.builder(
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final product = state.favorites[index];

                  // Vérifiez et corrigez l'URL de l'image si nécessaire
                  String imageUrl = product.imageUrl;
                  if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
                    imageUrl = 'https://via.placeholder.com/150';
                  }

                  final favorite = Favorite(
                    id: product.id,
                    uid: uid,
                    productId: product.productId,
                    productName: product.productName.isNotEmpty
                        ? product.productName
                        : 'Produit inconnu',
                    imageUrl: imageUrl,
                    timestamp: DateTime.now().toIso8601String(),
                  );
                  return FavoriteCard(favorite: favorite);
                },
              );
            } else if (state is FavoriteError) {
              return Center(
                  child: Text(state.errorMessage ?? 'Une erreur est survenue'));
            } else {
              return const Center(child: Text('Aucun favori trouvé'));
            }
          },
        ),
      ),
    );
  }
}