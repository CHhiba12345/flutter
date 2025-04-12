import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

class HomeDataSource {
  static const String _baseUrl = "https://b04e-197-20-218-0.ngrok-free.app/products";

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
          return model.copyWith(isFavorite: isFav).toEntity(); // 👈 Ici
        }).toList();
      } else if (decodedResponse is Map && decodedResponse.containsKey('products')) {
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
