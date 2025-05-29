// Événements liés à l'authentification

/// Classe abstraite représentant un événement d'authentification
abstract class AuthEvent {}

/// Événement déclenché lors d'une tentative de connexion par email/mot de passe
class SignInWithEmailAndPasswordEvent extends AuthEvent {
  final String email;
  final String password;

  SignInWithEmailAndPasswordEvent(this.email, this.password);
}

/// Événement déclenché lors d'une inscription via email/mot de passe
class SignUpWithEmailAndPasswordEvent extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  SignUpWithEmailAndPasswordEvent(
      this.email,
      this.password,
      this.firstName,
      this.lastName,
      );
}

/// Événement pour une connexion via Google
class SignInWithGoogleEvent extends AuthEvent {}

/// Événement pour une connexion via Facebook
class SignInWithFacebookEvent extends AuthEvent {}

/// Événement pour une déconnexion utilisateur
class SignOutEvent extends AuthEvent {}

/// Événement pour demander la réinitialisation du mot de passe
class ForgotPasswordRequested extends AuthEvent {
  final String email;

  ForgotPasswordRequested(this.email);
}

/// Événement pour confirmer la réinitialisation du mot de passe
class PasswordResetRequested extends AuthEvent {
  final String oobCode;
  final String newPassword;

  PasswordResetRequested(this.oobCode, this.newPassword);
}