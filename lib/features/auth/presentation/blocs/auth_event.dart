// Classe abstraite représentant un événement d'authentification
abstract class AuthEvent {}

/// Événement pour la connexion avec un email et un mot de passe
class SignInWithEmailAndPasswordEvent extends AuthEvent {
  final String email;  // Adresse email de l'utilisateur
  final String password;  // Mot de passe de l'utilisateur

  /// Constructeur pour initialiser l'email et le mot de passe
  SignInWithEmailAndPasswordEvent(this.email, this.password);
}

/// Événement pour l'inscription avec un email et un mot de passe
class SignUpWithEmailAndPasswordEvent extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  SignUpWithEmailAndPasswordEvent(
      this.email,
      this.password,
      this.firstName,
      this.lastName,);
}

/// Événement pour la connexion avec Google
class SignInWithGoogleEvent extends AuthEvent {
  // Aucun paramètre nécessaire pour cet événement
}

/// Événement pour la connexion avec Facebook
class SignInWithFacebookEvent extends AuthEvent {
  // Aucun paramètre nécessaire pour cet événement
}

/// Événement pour la déconnexion de l'utilisateur
class SignOutEvent extends AuthEvent {
  // Aucun paramètre nécessaire pour cet événement
}
// Ajoutez ces nouveaux événements
class ForgotPasswordRequested extends AuthEvent {
  final String email;
  ForgotPasswordRequested(this.email);
}

class PasswordResetRequested extends AuthEvent {
  final String oobCode;
  final String newPassword;

   PasswordResetRequested(this.oobCode, this.newPassword);
}
