import '../../domain/entities/app_user.dart';

/// Classe abstraite représentant les états d'authentification
abstract class AuthState {}

// État initial — Aucune action en cours
class AuthInitial extends AuthState {}

// État de chargement — Une opération est en cours
class AuthLoading extends AuthState {}

// Connexion réussie avec utilisateur connecté
class AuthSuccess extends AuthState {
  final AppUser user;

  AuthSuccess(this.user);
}

// Erreur générale d'authentification
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

// L'utilisateur existe déjà (ex: email déjà utilisé)
class AuthEmailAlreadyExistsError extends AuthState {}

// === Mot de passe oublié ===

// Envoi de l'email de réinitialisation réussi
class ForgotPasswordSuccess extends AuthState {
  final String message;

  ForgotPasswordSuccess(this.message);
}

// Chargement lors de la demande de réinitialisation
class ForgotPasswordLoading extends AuthState {}

// Erreur lors de la demande de réinitialisation
class ForgotPasswordError extends AuthState {
  final String message;

  ForgotPasswordError(this.message);
}

// === Réinitialisation du mot de passe ===

// Confirmation de réinitialisation en cours
class ResetPasswordLoading extends AuthState {}

// Réinitialisation réussie
class ResetPasswordSuccess extends AuthState {}

// Erreur lors de la réinitialisation
class ResetPasswordError extends AuthState {
  final String message;

  ResetPasswordError(this.message);
}