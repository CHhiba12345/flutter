// Use case pour la réinitialisation du mot de passe
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  // Confirme la réinitialisation du mot de passe avec le code et le nouveau mot de passe
  Future<void> execute(String oobCode, String newPassword) async {
    await repository.confirmPasswordReset(oobCode, newPassword);
  }
}