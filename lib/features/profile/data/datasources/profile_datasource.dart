import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../auth/data/datasources/auth_service.dart';

abstract class ProfileDataSource {
  Future<List<String>> setUserAllergens(String uid, List<String> allergens);
  Future<List<String>> getUserAllergens(String uid);
  Future<void> clearUserAllergens(String uid);
}
class ProfileDataSourceImpl implements ProfileDataSource {
  final http.Client client;
  final AuthService authService;


  static const String _baseUrl = "http://164.132.53.159:3002";

  ProfileDataSourceImpl({required this.client, required this.authService});

  Future<Map<String, String>> _getHeaders() async {
    final token = await authService.getCurrentUserToken();
    if (token == null) throw Exception('User not authenticated');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<String>> setUserAllergens(String uid, List<String> allergens) async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('$_baseUrl/users/allergens'),
      headers: headers,
      body: json.encode({'uid': uid, 'allergens': allergens}),
    );

    if (response.statusCode == 200) {
      // Attendre un peu pour être sûr que le serveur a bien traité la requête
      await Future.delayed(const Duration(milliseconds: 300));

      // Recharger les données fraîches
      final freshResponse = await client.get(
        Uri.parse('$_baseUrl/users/$uid/allergens'),
        headers: headers,
      );

      if (freshResponse.statusCode == 200) {
        return List<String>.from(json.decode(freshResponse.body));
      }
    }
    throw Exception('Failed to save allergens');
  }

  @override
  Future<List<String>> getUserAllergens(String uid) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$_baseUrl/users/$uid/allergens'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load allergens: ${response.statusCode}');
    }
  }

  @override
  Future<void> clearUserAllergens(String uid) async {
    final headers = await _getHeaders();
    final response = await client.delete(
      Uri.parse('$_baseUrl/users/$uid/allergens'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear allergens: ${response.statusCode}');
    }
  }
}