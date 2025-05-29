import '../repositories/auth_repository.dart';
import '../entities/app_user.dart';

/// Inscription via email et mot de passe
class SignUpWithEmailAndPassword {
  final AuthRepository repository;

  SignUpWithEmailAndPassword(this.repository);

  /// Crée un compte utilisateur avec email et mot de passe
  Future<AppUser> call(
      String email,
      String password,
      String firstName,
      String lastName,
      ) {
    return repository.signUpWithEmailAndPassword(email, password, firstName, lastName);
  }
}