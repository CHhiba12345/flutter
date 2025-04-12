import '../repositories/auth_repository.dart';
import '../entities/app_user.dart';

class SignUpWithEmailAndPassword {
  final AuthRepository repository;

  SignUpWithEmailAndPassword(this.repository);

  Future<AppUser> call(String email, String password) {
    return repository.signUpWithEmailAndPassword(email, password);
  }
}