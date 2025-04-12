import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

class HomeDataSource {
  static const String _baseUrl = "https://ef1d-197-23-137-142.ngrok-free.app/products";

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
    final uri = Uri.parse("$_baseUrl/search/$name");
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $jwtToken'},
    );
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse is List) {
        return decodedResponse.map((json) =>
            ProductModel.fromJson(json).toEntity()).toList();
      } else
      if (decodedResponse is Map && decodedResponse.containsKey('products')) {
        final products = decodedResponse['products'] as List;
        return products
            .map((json) => ProductModel.fromJson(json).toEntity())
            .toList();
      }
      throw FormatException('Format JSON inattendu');
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
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