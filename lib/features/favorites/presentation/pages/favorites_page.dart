import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        addToFavorites: AddToFavorites(context.read<FavoriteRepository>()),
        removeFromFavorites: RemoveFromFavorites(context.read<FavoriteRepository>()),
        getFavorites: GetFavorites(context.read<FavoriteRepository>()),
      )..add(LoadFavoritesEvent(uid: uid)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mes Favoris')),
        body: BlocBuilder<FavoriteBloc, FavoriteState>(
          builder: (context, state) {
            if (state is FavoriteLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FavoritesLoaded) {
              return ListView.builder(
                itemCount: state.favorites.length,
                itemBuilder: (context, index) => FavoriteCard(favorite: state.favorites[index]),
              );
            } else if (state is FavoriteError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Aucun favori'));
          },
        ),
      ),
    );
  }
}