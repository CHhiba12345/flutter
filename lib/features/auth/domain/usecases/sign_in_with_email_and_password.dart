import '../repositories/auth_repository.dart';
import '../entities/app_user.dart';

/// Cas d'utilisation pour la connexion avec email et mot de passe.
///
/// Permet d'exécuter l'authentification via le dépôt d'authentification.
class SignInWithEmailAndPassword {
  final AuthRepository repository; // Référencement du dépôt d'authentification

  /// Constructeur injectant le dépôt d'authentification
  SignInWithEmailAndPassword(this.repository);

  /// Exécute la connexion avec email et mot de passe
  ///
  /// Retourne un [AppUser] en cas de succès
  Future<AppUser> call(String email, String password) {
    return repository.signInWithEmailAndPassword(email, password);
  }
}
