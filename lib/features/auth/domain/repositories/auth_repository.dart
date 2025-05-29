import '../entities/app_user.dart';

// ============================================================================
// 📌 INTERFACE : AuthRepository
// ----------------------------------------------------------------------------
// Définit les opérations que le domaine peut effectuer sur l'authentification.
// Cette abstraction est utilisée par les cas d'utilisation (use cases) du domaine,
// indépendamment de l'implémentation technique (Firebase, API, etc.).
// ============================================================================

abstract class AuthRepository {
  // ===========================================================================
  // 🔐 AUTHENTIFICATION EMAIL / MOT DE PASSE
  // ===========================================================================

  /// Connecte un utilisateur avec son email et mot de passe.
  Future<AppUser> signInWithEmailAndPassword(String email, String password);

  /// Inscrit un nouvel utilisateur avec email, mot de passe et nom.
  Future<AppUser> signUpWithEmailAndPassword(
      String email,
      String password,
      String firstName,
      String lastName);

  // ===========================================================================
  // 🟡 GOOGLE SIGN-IN
  // ===========================================================================

  /// Connexion via Google.
  Future<AppUser?> signInWithGoogle();

  // ===========================================================================
  // 🔵 FACEBOOK SIGN-IN
  // ===========================================================================

  /// Connexion via Facebook.
  Future<AppUser?> signInWithFacebook();

  // ===========================================================================
  // 🔚 DÉCONNEXION
  // ===========================================================================

  /// Déconnecte l'utilisateur.
  Future<void> signOut();

  // ===========================================================================
  // 🔐 GESTION DES TOKENS
  // ===========================================================================

  /// Récupère le token Firebase actuel de l'utilisateur.
  Future<String?> getFirebaseToken();

  /// Récupère l'identifiant utilisateur à partir du token stocké.
  Future<String?> getUserId();

  // ===========================================================================
  // 📧 RÉINITIALISATION DU MOT DE PASSE
  // ===========================================================================

  /// Envoie un email de réinitialisation du mot de passe.
  Future<void> sendPasswordResetEmail(String email);

  /// Confirme la réinitialisation du mot de passe avec un code et un nouveau mot de passe.
  Future<void> confirmPasswordReset(String oobCode, String newPassword);
}