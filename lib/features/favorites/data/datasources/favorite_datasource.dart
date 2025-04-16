import 'dart:convert';
import 'package:eye_volve/features/favorites/data/models/favorite_model.dart';
import 'package:eye_volve/features/home/data/models/product_model.dart';
import 'package:eye_volve/features/home/domain/entities/product.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class FavoriteDataSource {
  final String jwtToken;
  static const String baseUrl= "https://65a5-197-18-42-245.ngrok-free.app";

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
  Future<List<FavoriteModel>> getFavorites(String uid) async {
    final url = Uri.parse('$baseUrl/favorites').replace(queryParameters: {'uid': uid});
    final response = await http.get(url, headers: _buildHeaders());
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      print("Réponse JSON complète pour les favoris : $jsonResponse");

      return jsonResponse.map((e) => FavoriteModel.fromJson(e)).toList();
    } else {
      throw Exception('Échec de la récupération des favoris : ${response.statusCode}');
    }
  }
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    };
  }
}