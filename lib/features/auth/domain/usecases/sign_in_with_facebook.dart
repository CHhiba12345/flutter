import '../repositories/auth_repository.dart';
import '../entities/app_user.dart';

/// Connexion via Facebook
class SignInWithFacebook {
  final AuthRepository repository;

  SignInWithFacebook(this.repository);

  /// Tente une connexion avec Facebook
  Future<AppUser?> call() => repository.signInWithFacebook();
}