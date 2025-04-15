
import '../entities/app_user.dart'; //

abstract class AuthRepository {
  Future<AppUser> signInWithEmailAndPassword(String email, String password);
  Future<AppUser> signUpWithEmailAndPassword(
      String email,
      String password,
      String firstName,
      String lastName,
      );
  Future<void> signOut();
  Future<AppUser?> signInWithGoogle();
  Future<AppUser?> signInWithFacebook();
  Future<String?> getFirebaseToken();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> confirmPasswordReset(String oobCode, String newPassword);
  Future<String?> getUserId();
}
///=============interface définir l'accés au données