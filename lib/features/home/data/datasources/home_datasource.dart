import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

class HomeDataSource {
  static const String _baseUrl = "https://b04e-197-20-218-0.ngrok-free.app/products";

  final String jwtToken;

  HomeDataSource({required this.jwtToken});


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
    print('[HomeDataSource] Searching for: $name');
    final uri = Uri.parse("$_baseUrl/search/$name");
    print('[HomeDataSource] Search URL: ${uri.toString()}');

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $jwtToken'},
      );

      print('[HomeDataSource] Response Code: ${response.statusCode}');
      print('[HomeDataSource] Full Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        print('[HomeDataSource] Decoded Response: $decodedResponse');

        // Ajouter une logique de fallback supplémentaire
        if (decodedResponse is List) {
          return decodedResponse.map((json) => ProductModel.fromJson(json).toEntity()).toList();
        }

        if (decodedResponse is Map) {
          if (decodedResponse.containsKey('data')) {
            return (decodedResponse['data'] as List).map((json) => ProductModel.fromJson(json).toEntity()).toList();
          }
          if (decodedResponse.containsKey('products')) {
            return (decodedResponse['products'] as List).map((json) => ProductModel.fromJson(json).toEntity()).toList();
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

  String _handleHttpError(int statusCode) {
    switch (statusCode) {
      case 404:
        return 'Product not found';
      case 400:
        return 'Invalid request';
      case 500:
        return 'Server error';
      default:
        return 'HTTP error $statusCode';
    }
  }
}
