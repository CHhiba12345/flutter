import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

class HomeDataSource {
  static const String _baseUrl =
      "https://b04e-197-20-218-0.ngrok-free.app/products";

  final String jwtToken;
  final List<Product> favorisList; // 👈 Ajout de la liste des favoris locale

  HomeDataSource({
    required this.jwtToken,
    required this.favorisList, // 👈 Injecte la liste dans le constructeur
  });

  Future<Map<String, dynamic>> getProductData(String code) async {
    final uri = Uri.parse("$_baseUrl/$code");
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Produit non trouvé');
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }
  }

  ///
  /// Call the endpoind["/favorites/toggle"] that return an array object
  /// as params body contain the [productid] and [uid]
  /// {"action":"added"} if product not find in table favorite
  /// {"action":"removed"} if user untoggle the favorite button
  ///
  Future<Map<String, dynamic>> getProductFavorite(
      String uid, String productid) async {
    final uri = Uri.parse("$_baseUrl/favorites/toggle");
    final response = await http.post(uri,
        headers: {'Authorization': 'Bearer $jwtToken'},
        body: {"uuid": uid, "product_id": productid});
    if (response.statusCode == 201) {
      return {"action": "added"};
    } else if (response.statusCode == 200) {
      return {"action": "removed"};
    } else if (response.statusCode == 404) {
      throw Exception("prodcution Not Found");
    } else {
      throw Exception("something want wrong");
    }
  }

  ///
  /// need to reformat the code almost of the function is wrong
  /// we need just return List of [Product]
  ///
  Future<List<Product>> searchProductByName(String name) async {
    final uri = Uri.parse("$_baseUrl/search/$name");
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);

      if (decodedResponse is List) {
        return decodedResponse.map<Product>((json) {
          ProductModel model = ProductModel.fromJson(json);
          bool isFav = favorisList.any((fav) => fav.code == model.code);

          /// ????????
          return model.copyWith(isFavorite: isFav).toEntity(); // 👈 Ici
        }).toList();
      } else if (decodedResponse is Map &&
          decodedResponse.containsKey('products')) {
        final products = decodedResponse['products'] as List;
        return products.map<Product>((json) {
          ProductModel model = ProductModel.fromJson(json);
          bool isFav = favorisList.any((fav) => fav.code == model.code);
          return model.copyWith(isFavorite: isFav).toEntity(); // 👈 Ici aussi
        }).toList();
      }

      throw FormatException('Format JSON inattendu');
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }
  }
}
