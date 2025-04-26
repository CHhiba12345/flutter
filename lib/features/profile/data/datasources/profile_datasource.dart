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
    print('🔑 Getting auth token...');
    final token = await authService.getCurrentUserToken();
    if (token == null) throw Exception('User not authenticated');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<String>> setUserAllergens(String uid, List<String> allergens) async {
    print('📤 [setUserAllergens] START | uid: $uid | allergens: $allergens');

    try {
      final headers = await _getHeaders();
      print('📡 Sending to server: ${{'uid': uid, 'allergens': allergens}}');

      final response = await client.post(
        Uri.parse('$_baseUrl/users/allergens'),
        headers: headers,
        body: json.encode({'uid': uid, 'allergens': allergens}),
      );

      print('⚡ Server response: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        print('⏳ Waiting 300ms for server processing...');
        await Future.delayed(const Duration(milliseconds: 300));

        print('🔄 Fetching fresh data...');
        final freshResponse = await client.get(
          Uri.parse('$_baseUrl/users/$uid/allergens'),
          headers: headers,
        );

        print('🔍 Fresh data response: ${freshResponse.statusCode} | ${freshResponse.body}');

        if (freshResponse.statusCode == 200) {
          final freshData = List<String>.from(json.decode(freshResponse.body));
          print('✅ [setUserAllergens] SUCCESS | New allergens: $freshData');
          return freshData;
        }
      }
      throw Exception('Failed to save allergens');
    } catch (e) {
      print('❌ [setUserAllergens] ERROR: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<String>> getUserAllergens(String uid) async {
    print('📥 [getUserAllergens] START | uid: $uid');

    try {
      final headers = await _getHeaders();
      print('🌐 Fetching allergens from server...');

      final response = await client.get(
        Uri.parse('$_baseUrl/users/$uid/allergens'),
        headers: headers,
      );

      print('📊 Server response: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        final allergens = List<String>.from(json.decode(response.body));
        print('✅ [getUserAllergens] SUCCESS | Allergens: $allergens');
        return allergens;
      } else if (response.statusCode == 404) {
        print('ℹ️ No allergens found (404), returning empty list');
        return [];
      } else {
        throw Exception('Failed to load allergens: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [getUserAllergens] ERROR: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> clearUserAllergens(String uid) async {
    print('🧹 [clearUserAllergens] START | uid: $uid');

    try {
      final headers = await _getHeaders();
      print('🗑 Sending delete request...');

      final response = await client.delete(
        Uri.parse('$_baseUrl/users/$uid/allergens'),
        headers: headers,
      );

      print('♻️ Server response: ${response.statusCode} | ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to clear allergens: ${response.statusCode}');
      }
      print('✅ [clearUserAllergens] SUCCESS');
    } catch (e) {
      print('❌ [clearUserAllergens] ERROR: ${e.toString()}');
      rethrow;
    }
  }
}