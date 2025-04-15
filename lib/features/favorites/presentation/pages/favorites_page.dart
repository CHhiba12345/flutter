import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
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
  final String uid;

  const FavoritesPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoriteBloc(
        addToFavorites: AddToFavorites(Provider.of<FavoriteRepository>(context, listen: false)),
        removeFromFavorites: RemoveFromFavorites(Provider.of<FavoriteRepository>(context, listen: false)),
        getFavorites: GetFavorites(Provider.of<FavoriteRepository>(context, listen: false)),
      )..add(LoadFavoritesEvent(uid: uid)), // Ensure the uid is passed correctly
      child: Scaffold(
        appBar: AppBar(title: const Text('Mes Favoris')),
        body: BlocBuilder<FavoriteBloc, FavoriteState>(
          builder: (context, state) {
            // Loading state
            if (state is FavoriteLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            // Loaded state
            else if (state is FavoritesLoaded) {
              return ListView.builder(
                itemCount: state.favorites.length,
                  itemBuilder: (context, index) {
                    final product = state.favorites[index]; // Supposons que ce soit un Product
                    final favorite = Favorite(
                      id: product.code,
                      uid: uid,
                      productId: product.code,
                      productName: product.name,
                      imageUrl: product.imageUrl,
                      timestamp: DateTime.now().toIso8601String(),
                    );
                    return FavoriteCard(favorite: favorite);
                  },
              );
            }
            // Error state
            else if (state is FavoriteError) {
              return Center(child: Text(state.errorMessage ?? 'An error occurred'));
            }
            // Default case when no favorites are available
            return const Center(child: Text('Aucun favori'));
          },
        ),
      ),
    );
  }
}
