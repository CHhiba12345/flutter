import 'package:eye_volve/features/home/data/models/product_model.dart';
import 'package:eye_volve/features/home/domain/entities/product.dart';

import '../entities/favorite.dart';
import '../repositories/favorite_repository.dart';

class GetFavorites {
  final FavoriteRepository repository;

  GetFavorites(this.repository);

  Future<Future<List<Product>>> execute(String uid) async {
    return repository.getFavorites(uid);
  }
}