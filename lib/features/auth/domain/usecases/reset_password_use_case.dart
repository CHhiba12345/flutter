// fichier: lib/domain/usecases/reset_password_use_case.dart
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute(String oobCode, String newPassword) =>
      repository.confirmPasswordReset(oobCode, newPassword);
}