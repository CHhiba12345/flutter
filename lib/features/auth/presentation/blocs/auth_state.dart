import '../../domain/entities/app_user.dart';

abstract class AuthState {}

// État initial
class AuthInitial extends AuthState {}

// État de chargement
class AuthLoading extends AuthState {}

// État de succès
class AuthSuccess extends AuthState {
  final AppUser user;

  AuthSuccess(this.user);
}

// État d'erreur
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

// État pour indiquer que l'email de réinitialisation a été envoyé
class ForgotPasswordSuccess extends AuthState {
  final String message;

  ForgotPasswordSuccess(this.message); // Constructeur avec paramètre obligatoire
}

class ForgotPasswordLoading extends AuthState {}
class ForgotPasswordError extends AuthState {
  final String message;
  ForgotPasswordError(this.message);
}

class ResetPasswordLoading extends AuthState {}
class ResetPasswordSuccess extends AuthState {}
class ResetPasswordError extends AuthState {
  final String message;
  ResetPasswordError(this.message);
}

class AuthEmailAlreadyExistsError extends AuthState {}