import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../auth/data/datasources/auth_service.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

// Classe principale pour la source de données de l'écran d'accueil
class HomeDataSource {
  static const String _baseUrl = "http://164.132.53.159:3002/products";
  final AuthService _authService = AuthService();

  // Méthode privée pour obtenir les headers avec le token d'authentification
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getCurrentUserToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Méthode pour obtenir les données d'un produit spécifique par son code
  Future<Map<String, dynamic>> getProductData(String code) async {
    final uri = Uri.parse("$_baseUrl/$code");
    final headers = await _getHeaders();

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 404) {
      throw Exception('Produit non trouvé');
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }
  }

  // Méthode pour rechercher des produits par nom
  Future<List<Product>> searchProductByName(String name) async {
    print('[HomeDataSource] Searching for: $name');
    final uri = Uri.parse("$_baseUrl/search/$name");
    print('[HomeDataSource] Search URL: ${uri.toString()}');
    final headers = await _getHeaders();

    try {
      final response = await http.get(
        uri,
        headers: headers,
      );

      print('[HomeDataSource] Response Code: ${response.statusCode}');
      print('[HomeDataSource] Full Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(utf8.decode(response.bodyBytes)); // ✅ UTF-8 fix
        print('[HomeDataSource] Decoded Response: $decodedResponse');

        if (decodedResponse is List) {
          return decodedResponse.map((json) =>
              ProductModel.fromJson(json).toEntity()).toList();
        }

        if (decodedResponse is Map) {
          if (decodedResponse.containsKey('data')) {
            return (decodedResponse['data'] as List).map((json) =>
                ProductModel.fromJson(json).toEntity()).toList();
          }
          if (decodedResponse.containsKey('products')) {
            return (decodedResponse['products'] as List).map((json) =>
                ProductModel.fromJson(json).toEntity()).toList();
          }
        }

        throw FormatException('[HomeDataSource] Structure JSON inattendue');
      } else {
        throw Exception('[HomeDataSource] Erreur HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('[HomeDataSource] Error during search: $e');
      rethrow;
    }
  }

  // Méthode pour gérer les favoris d'un produit
  Future<Map<String, dynamic>>getProductFavorite(
      String uid,
      String productid,
      ) async {
    final uri = Uri.parse("$_baseUrl/favorites/toggle");
    final headers = await _getHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'uid': uid,
        'product_id': productid,
      }),
    );


    if (response.statusCode == 201) {
      return {"action": "added"};
    } else if (response.statusCode == 200) {
      return {"action": "removed"};
    } else if (response.statusCode == 404) {
      throw Exception("Product Not Found");
    } else {
      throw Exception("Erreur: ${response.statusCode}");
    }
  }
}