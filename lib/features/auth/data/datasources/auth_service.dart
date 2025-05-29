import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
    final FlutterSecureStorage _storage = const FlutterSecureStorage();
    final String baseUrl = "http://164.132.53.159:3001";
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    // ===========================================================================
    // 🔐 GESTION DE LA CONNEXION ET TOKEN : Vérification et persistance
    // ===========================================================================

    /// Vérifie si l'utilisateur est connecté via le token stocké.
    Future<bool> isUserLoggedIn() async {
        final token = await getToken();
        if (token == null) return false;

        try {
            final isValid = !JwtDecoder.isExpired(token);
            if (!isValid) await _storage.delete(key: 'firebase_token');
            return isValid;
        } catch (e) {
            return false;
        }
    }

    /// Affiche les informations de l'utilisateur actuel (UID).
    Future<void> printCurrentUserInfo() async {
        final token = await getCurrentUserToken();
        if (token == null) {
            print('Aucun token trouvé - utilisateur non connecté');
            return;
        }

        try {
            final decodedToken = JwtDecoder.decode(token);
            final uid = decodedToken['user_id'] ?? decodedToken['sub'] ?? 'Non trouvé';
            print('🔐 Token JWT décodé - UID: $uid');
        } catch (e) {
            print('Erreur de décodage du token: $e');
        }
    }

    // ===========================================================================
    // 🗃️ GESTION DES TOKENS : Stockage, lecture et extraction d'ID utilisateur
    // ===========================================================================

    /// Stocke un token dans le stockage sécurisé.
    Future<void> storeToken(String token) async {
        await _storage.write(key: 'firebase_token', value: token);
    }

    /// Récupère le token depuis le stockage sécurisé.
    Future<String?> getToken() async {
        return await _storage.read(key: 'firebase_token');
    }

    /// Extrait l'ID utilisateur à partir du token JWT.
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

    // ===========================================================================
    // 🔁 SYNCHRONISATION ET VALIDATION DES TOKENS : Firebase + Backend
    // ===========================================================================

    /// Vérifie le token Firebase auprès du backend et le stocke localement.
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

    /// Met à jour le token JWT en récupérant un nouveau token Firebase.
    Future<void> updateToken() async {
        try {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
                throw Exception("Aucun utilisateur connecté");
            }

            final token = await user.getIdToken();
            if (token == null) {
                throw Exception("Le token Firebase est null");
            }

            await storeToken(token);

            print("Token JWT mis à jour et stocké localement.");
            await printCurrentUserInfo();
        } catch (e) {
            print("Erreur lors de la mise à jour du token : $e");
            throw Exception("Erreur lors de la mise à jour du token : $e");
        }
    }

    /// Récupère le token courant (stocké ou depuis Firebase).
    Future<String?> getCurrentUserToken() async {
        String? token = await _storage.read(key: 'firebase_token');
        if (token != null) {
            return token;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
            token = await user.getIdToken();
            if (token != null) {
                await storeToken(token);
                return token;
            }
        }
        return null;
    }

    /// Récupère l'ID de l'utilisateur connecté à partir du token.
    Future<String?> getCurrentUserId() async {
        try {
            final token = await getCurrentUserToken();
            if (token == null) {
                throw Exception("Aucun token trouvé pour l'utilisateur connecté");
            }
            return await getUserIdFromToken(token);
        } catch (e) {
            print("Erreur lors de la récupération de l'ID utilisateur : $e");
            return null;
        }
    }

    // ===========================================================================
    // 📨 MOT DE PASSE OUBLIÉ : Réinitialisation via Firebase Auth
    // ===========================================================================

    /// Envoie un email de réinitialisation du mot de passe.
    Future<void> sendPasswordResetEmail(String email) async {
        try {
            await _firebaseAuth.sendPasswordResetEmail(email: email);
        } catch (e) {
            throw Exception("Erreur lors de l'envoi de l'email : $e");
        }
    }

    /// Confirme la réinitialisation du mot de passe avec le code reçu.
    Future<void> confirmPasswordReset(String oobCode, String newPassword) async {
        try {
            await _firebaseAuth.confirmPasswordReset(code: oobCode, newPassword: newPassword);
        } catch (e) {
            throw Exception("Erreur lors de la confirmation : $e");
        }
    }
}