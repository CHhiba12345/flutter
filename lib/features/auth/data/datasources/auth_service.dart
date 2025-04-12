import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import '../../../../core/errors/auth_exception.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
    final FlutterSecureStorage _storage = const FlutterSecureStorage();
    final String baseUrl = "https://ef1d-197-23-137-142.ngrok-free.app";


    Future<void> storeToken(String token) async {
        await _storage.write(key: 'firebase_token', value: token);
    }

    Future<String?> getToken() async {
        return await _storage.read(key: 'firebase_token');
    }

    Future<String> getUserIdFromToken(String token) async {
        try {
            final decodedToken = JwtDecoder.decode(token);
            final userId = decodedToken['user_id'];
            if (userId == null) throw Exception("Clé 'user_id' manquante dans le token");
            return userId.toString();
        } catch (e) {
            throw Exception("Erreur décodage token : ${e.toString()}");
        }
    }
    Future<void> verifyFirebaseToken(String firebaseToken) async {
        try {
            final response = await http.post(
                Uri.parse('$baseUrl/auth/verify-token'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'token': firebaseToken}),
            );

            if (response.statusCode != 200) {
                throw Exception("Erreur backend (${response.statusCode}) : ${response.body}");
            }

            await storeToken(firebaseToken);
        } catch (e) {
            throw Exception("Échec vérification token : ${e.toString()}");
        }
    }
    Future<void> sendForgotPasswordRequest(String email) async {
        if (!EmailValidator.validate(email)) {
            throw AuthException(message: 'Format email invalide');
        }

        try {
            final response = await http.post(
                Uri.parse('$baseUrl/auth/forgot-password'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'email': email}),
            );

            if (response.statusCode != 200) {
                throw AuthException(
                    message: 'Erreur lors de l\'envoi',
                    code: response.statusCode.toString(),
                );
            }
        } on SocketException {
            throw AuthException(message: 'Pas de connexion Internet');
        } on http.ClientException {
            throw AuthException(message: 'Serveur injoignable');
        }
    }

    Future<void> resetPassword(String oobCode, String newPassword) async {
        try {
            final response = await http.post(
                Uri.parse('$baseUrl/auth/reset-password'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                    'oobCode': oobCode,
                    'newPassword': newPassword,
                }),
            );

            if (response.statusCode != 200) {
                throw Exception('Erreur lors de la réinitialisation');
            }
        } catch (e) {
            throw Exception('Erreur réseau: $e');
        }
    }

    Future<void> updateToken() async {
        try {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
                throw Exception("Aucun utilisateur connecté");
            }

            // Récupération du token JWT
            final token = await user.getIdToken();
            if (token == null) {
                throw Exception("Le token Firebase est null");
            }

            // Stockage sécurisé du token
            await storeToken(token);

            print("Token JWT mis à jour et stocké localement.");
        } catch (e) {
            print("Erreur lors de la mise à jour du token : $e");
            throw Exception("Erreur lors de la mise à jour du token : $e");
        }
    }

    Future<String?> getCurrentUserToken() async {
        String? token = await _storage.read(key: 'firebase_token');
        if (token != null) {
            return token;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
            token = await user.getIdToken();
            if (token != null) {
                await storeToken(
                    token); // Stocke le token pour une utilisation future
                return token;
            }
        }
        return null; // Retourne null si aucun token n'est trouvé
    }
}