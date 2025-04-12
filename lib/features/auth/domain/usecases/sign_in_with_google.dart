import '../repositories/auth_repository.dart';
import '../entities/app_user.dart';

/// Cas d'utilisation pour la connexion avec Google.
///
/// Permet d'exécuter l'authentification via le dépôt d'authentification.
class SignInWithGoogle {
  final AuthRepository repository; // Référencement du dépôt d'authentification

  /// Constructeur injectant le dépôt d'authentification
  SignInWithGoogle(this.repository);

  /// Exécute la connexion avec Google
  ///
  /// Retourne un [AppUser] en cas de succès, sinon null
  Future<AppUser?> call() {
    return repository.signInWithGoogle();
  }
}
