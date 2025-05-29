import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/app_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ===========================================================================
  // 🔐 AUTHENTIFICATION EMAIL / MOT DE PASSE
  // ===========================================================================

  /// Connexion avec email et mot de passe.
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception("Utilisateur non trouvé");

      final token = await user.getIdToken();
      if (token == null) throw Exception("Token non généré");

      final userEmail = user.email;
      if (userEmail == null) throw Exception("Email non trouvé");

      await storeTokenLocally(token);

      final displayName = user.displayName?.split(' ') ?? [];
      return AppUser(
        uid: user.uid,
        email: userEmail,
        jwt: token,
        firstName: displayName.isNotEmpty ? displayName[0] : '',
        lastName: displayName.length > 1 ? displayName.sublist(1).join(' ') : '',
      );
    } catch (e) {
      throw Exception("Erreur de connexion : ${e.toString()}");
    }
  }

  /// Création d'un compte utilisateur avec email et mot de passe.
  Future<AppUser> signUpWithEmailAndPassword(
      String email,
      String password,
      String firstName,
      String lastName,) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception("Utilisateur non créé");

      await user.updateDisplayName("$firstName $lastName");
      await user.reload();

      final token = await user.getIdToken();
      if (token == null) throw Exception("Token non généré");

      final userEmail = user.email;
      if (userEmail == null) throw Exception("Email non trouvé");

      await storeTokenLocally(token);

      return AppUser(
        uid: user.uid,
        email: email,
        jwt: token,
        firstName: firstName,
        lastName: lastName,
      );
    } catch (e) {
      throw Exception("Erreur d'inscription : ${e.toString()}");
    }
  }

  // ===========================================================================
  // 🟡 GOOGLE SIGN-IN
  // ===========================================================================

  /// Connexion via Google.
  Future<AppUser?> signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      final token = await user.getIdToken();
      final userEmail = user.email;

      if (token == null || userEmail == null) return null;

      final displayName = user.displayName?.split(' ') ?? [];
      return AppUser(
        uid: user.uid,
        email: userEmail,
        jwt: token,
        firstName: displayName.isNotEmpty ? displayName[0] : '',
        lastName: displayName.length > 1 ? displayName.sublist(1).join(' ') : '',
      );
    } catch (e) {
      throw Exception("Erreur Google Sign-In : ${e.toString()}");
    }
  }

  // ===========================================================================
  // 🔵 FACEBOOK SIGN-IN
  // ===========================================================================

  /// Connexion via Facebook.
  Future<AppUser?> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status != LoginStatus.success) return null;

      final token = loginResult.accessToken?.token;
      if (token == null) throw Exception("Token Facebook manquant");

      final credential = FacebookAuthProvider.credential(token);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      final firebaseToken = await user.getIdToken();
      final userEmail = user.email;

      if (firebaseToken == null || userEmail == null) return null;

      final displayName = user.displayName?.split(' ') ?? [];
      return AppUser(
        uid: user.uid,
        email: userEmail,
        jwt: token,
        firstName: displayName.isNotEmpty ? displayName[0] : '',
        lastName: displayName.length > 1 ? displayName.sublist(1).join(' ') : '',
      );
    } catch (e) {
      throw Exception("Erreur Facebook Sign-In : ${e.toString()}");
    }
  }

  // ===========================================================================
  // 💾 GESTION DU TOKEN LOCAL
  // ===========================================================================

  /// Stocke le token Firebase dans un stockage sécurisé.
  Future<void> storeTokenLocally(String token) async {
    await _storage.write(key: 'firebase_token', value: token);
  }

  /// Récupère le token actuel depuis Firebase Auth.
  Future<String?> getFirebaseToken() async {
    return FirebaseAuth.instance.currentUser?.getIdToken();
  }

  // ===========================================================================
  // 🔚 DÉCONNEXION
  // ===========================================================================

  /// Déconnecte l'utilisateur et nettoie les données locales.
  Future<void> signOut() async {
    try {
      await _storage.delete(key: 'firebase_token');
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      throw Exception("Erreur déconnexion : ${e.toString()}");
    }
  }
}