import 'package:eye_volve/features/home/domain/entities/product.dart';
import 'package:eye_volve/features/home/domain/repositories/home_repository.dart';
import '../datasources/home_datasource.dart';
import '../models/product_model.dart';

// Implémentation concrète du repository Home
class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource homeDataSource;
  HomeRepositoryImpl({required this.homeDataSource});

  // Méthode pour récupérer un produit par son code
  @override
  Future<Product> getProduct(String code) async {
    try {
      final data = await homeDataSource.getProductData(code);
      return ProductModel.fromJson(data).toEntity();
    } catch (e) {
      throw Exception('Échec de la récupération du produit: $e');
    }
  }

  // Méthode pour rechercher des produits par requête textuelle
  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      print("Recherche de produits avec le terme : $query");
      final products = await homeDataSource.searchProductByName(query);
      print("Produits trouvés : $products");
      return products;
    } catch (e) {
      print("Erreur lors de la recherche de produits : $e");
      throw Exception('Échec de la recherche de produits: $e');
    }
  }

  // Méthode pour scanner un produit via son code-barres
  @override
  Future<Product> scanProduct(String barcode) async {
    try {
      final data = await homeDataSource.getProductData(barcode);
      return ProductModel.fromJson(data).toEntity();
    } catch (e) {
      throw Exception('Échec du scan du produit: $e');
    }
  }

  ///////////////////////////////////////////////////////////
  /// Fonction de type [Bool] qui renvoie au bloc pour mettre à jour
  /// le composant Icon-favorite
  ///////////////////////////////////////////////////////////
  @override
  Future<bool> getfavoriteProduct(String uid, String productid) async {
    try {
      final data = await homeDataSource.getProductFavorite(uid, productid);
      if (data["action"] == "added") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Échec du scan du produit: $e');
    }
  }
}