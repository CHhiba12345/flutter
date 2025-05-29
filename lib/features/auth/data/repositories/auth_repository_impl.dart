import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_service.dart';
import '../datasources/firebase_auth_data_source.dart';
import '../../../../core/errors/auth_exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;
  final AuthService authService;

  AuthRepositoryImpl(this.dataSource, this.authService);

  // ===========================================================================
  // 📦 SIGN IN / SIGN UP AVEC EMAIL & MOT DE PASSE
  // ===========================================================================

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    final user = await dataSource.signInWithEmailAndPassword(email, password);
    if (user.jwt == null) {
      throw AuthException(message: "Token JWT non généré");
    }
    await authService.verifyFirebaseToken(user.jwt!);
    return user;
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword(
      String email,
      String password,
      String firstName,
      String lastName,
      ) async {
    final user = await dataSource.signUpWithEmailAndPassword(
      email,
      password,
      firstName,
      lastName,
    );
    if (user.jwt == null) {
      throw AuthException(message: "Token JWT non généré");
    }
    await authService.verifyFirebaseToken(user.jwt!);
    return user;
  }

  // ===========================================================================
  // 🟡 GOOGLE SIGN-IN
  // ===========================================================================

  @override
  Future<AppUser?> signInWithGoogle() async {
    final user = await dataSource.signInWithGoogle();
    if (user != null) {
      await authService.verifyFirebaseToken(user.jwt!); // Envoyer le token au backend
    }
    return user;
  }

  // ===========================================================================
  // 🔵 FACEBOOK SIGN-IN
  // ===========================================================================

  @override
  Future<AppUser?> signInWithFacebook() async {
    final user = await dataSource.signInWithFacebook();
    if (user != null) {
      await authService.verifyFirebaseToken(user.jwt!); // Envoyer le token au backend
    }
    return user;
  }

  // ===========================================================================
  // 🔚 DÉCONNEXION
  // ===========================================================================

  @override
  Future<void> signOut() {
    return dataSource.signOut();
  }

  // ===========================================================================
  // 📧 RÉINITIALISATION DU MOT DE PASSE
  // ===========================================================================

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw AuthException(message: 'Erreur: ${e.toString()}');
    }
  }

  @override
  Future<void> confirmPasswordReset(String oobCode, String newPassword) async {
    try {
      await authService.confirmPasswordReset(oobCode, newPassword);
    } catch (e) {
      throw AuthException(message: 'Erreur: ${e.toString()}');
    }
  }

  // ===========================================================================
  // 🔍 UTILITAIRES : Récupération d'informations utilisateur
  // ===========================================================================

  /// Récupère l'UID de l'utilisateur à partir du token stocké localement.
  Future<String?> getUserId() async {
    try {
      final token = await authService.getToken(); // Récupère le token stocké localement
      if (token != null) {
        return authService.getUserIdFromToken(token); // Décoder le token pour extraire l'UID
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'UID: ${e.toString()}');
    }
  }

  // ===========================================================================
  // 🔐 RÉCUPÉRATION DES TOKENS
  // ===========================================================================

  /// Récupère le token Firebase actuel.
  @override
  Future<String?> getFirebaseToken() async {
    try {
      final user = await FirebaseAuth.instance.currentUser;
      return await user?.getIdToken(); // Récupère le token Firebase
    } catch (e) {
      throw AuthException(message: 'Erreur lors de la récupération du token Firebase: ${e.toString()}');
    }
  }
}