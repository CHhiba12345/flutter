import '../repositories/auth_repository.dart';

/// Déconnecte l'utilisateur de l'application
class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  /// Exécute la déconnexion
  Future<void> call() => repository.signOut();
}