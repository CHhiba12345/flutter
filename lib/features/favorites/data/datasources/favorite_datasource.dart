import 'dart:convert';
import 'package:eye_volve/features/home/data/models/product_model.dart';
import 'package:eye_volve/features/home/domain/entities/product.dart';
import 'package:http/http.dart' as http;

class FavoriteDataSource {
  final String jwtToken;
  static const String baseUrl= "https://ef1d-197-23-137-142.ngrok-free.app";

  FavoriteDataSource({required this.jwtToken});

  // Toggle un produit (ajout/suppression) dans les favoris
  Future<void> toggleFavorite({
    required String uid,
    required String productId,
  }) async {
    final url = Uri.parse('$baseUrl/favorites/toggle');
    final response = await http.post(
      url,
      headers: _buildHeaders(),
      body: jsonEncode({
        'uid': uid,
        'product_id': productId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to toggle favorite: ${response.statusCode}');
    }
  }

  // Récupère la liste des favoris pour un utilisateur donné
  // Récupère la liste des favoris pour un utilisateur donné
  Future<List<Product>> getFavorites(String uid) async {
    final url = Uri.parse('$baseUrl/favorites').replace(queryParameters: {'uid': uid});
    final response = await http.get(url, headers: _buildHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((e) => ProductModel.fromJson(e).toEntity()).toList();
    } else {
      throw Exception('Failed to load favorites: ${response.statusCode}');
    }
  }

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    };
  }
}