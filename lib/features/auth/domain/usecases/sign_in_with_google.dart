import '../repositories/auth_repository.dart';
import '../entities/app_user.dart';

/// Connexion via Google
class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  /// Tente une connexion avec Google
  ///
  /// Retourne un [AppUser] si réussi, sinon null
  Future<AppUser?> call() => repository.signInWithGoogle();
}