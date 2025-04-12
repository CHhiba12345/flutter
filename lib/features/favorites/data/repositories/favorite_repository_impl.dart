import 'package:eye_volve/features/home/data/models/product_model.dart';
import 'package:eye_volve/features/home/domain/entities/product.dart';

import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_datasource.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteDataSource dataSource;

  FavoriteRepositoryImpl({required this.dataSource});

  @override
  Future<void> toggleFavorite({required String uid, required String productId}) async {
    await dataSource.toggleFavorite(uid: uid, productId: productId);
  }

  @override
  Future<List<Product>> getFavorites(String uid) async {
    final favoriteList = await dataSource.getFavorites(uid);
    return favoriteList;
    //return favoriteList.toList(); // Convertir le Set en List
  }
}