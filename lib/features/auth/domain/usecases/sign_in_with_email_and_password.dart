import '../repositories/auth_repository.dart';
import '../entities/app_user.dart';

/// Connexion via email et mot de passe
class SignInWithEmailAndPassword {
  final AuthRepository repository;

  SignInWithEmailAndPassword(this.repository);

  /// Connecte l'utilisateur et retourne un [AppUser]
  Future<AppUser> call(String email, String password) {
    return repository.signInWithEmailAndPassword(email, password);
  }
}