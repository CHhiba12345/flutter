
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  /// Constructeur prenant en charge l'injection de dépendances.
  ForgotPasswordUseCase(this.repository);

  // ===========================================================================
  // 🔧 Exécution du cas d'utilisation
  // ===========================================================================


  /// Cette méthode est appelée depuis la présentation (ex: bloc ou page),et délègue l'action au repository.
  Future<void> execute(String email) async {
    await repository.sendPasswordResetEmail(email);
  }
}