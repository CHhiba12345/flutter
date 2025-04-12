// fichier: lib/domain/usecases/forgot_password_use_case.dart
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<void> execute(String email) => repository.sendPasswordResetEmail(email);
}

///gérer la logique métier spécifique