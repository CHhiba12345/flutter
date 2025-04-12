import '../repositories/auth_repository.dart';
import '../entities/app_user.dart';

class SignInWithFacebook {
  final AuthRepository repository;

  SignInWithFacebook(this.repository);

  Future<AppUser?> call() {
    return repository.signInWithFacebook();
  }
}