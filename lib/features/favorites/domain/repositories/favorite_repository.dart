import 'package:eye_volve/features/favorites/data/models/favorite_model.dart';
import 'package:eye_volve/features/home/data/models/product_model.dart';
import 'package:eye_volve/features/home/domain/entities/product.dart';

import '../entities/favorite.dart';

abstract class FavoriteRepository {
  Future<void> toggleFavorite({required String uid, required String productId});
  Future<List<FavoriteModel>> getFavorites(String uid);

}