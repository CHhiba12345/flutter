import 'package:email_validator/email_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/forgot_password_use_case.dart';
import '../../domain/usecases/reset_password_use_case.dart';
import '../../domain/usecases/sign_in_with_email_and_password.dart';
import '../../domain/usecases/sign_up_with_email_and_password.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_in_with_facebook.dart';
import '../../domain/usecases/sign_out.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailAndPassword signInWithEmailAndPassword;
  final SignUpWithEmailAndPassword signUpWithEmailAndPassword;
  final SignInWithGoogle signInWithGoogle;
  final SignInWithFacebook signInWithFacebook;
  final SignOut signOut;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signInWithEmailAndPassword,
    required this.signUpWithEmailAndPassword,
    required this.signInWithGoogle,
    required this.signInWithFacebook,
    required this.signOut,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<SignInWithEmailAndPasswordEvent>(_handleSignInWithEmailAndPassword);
    on<SignUpWithEmailAndPasswordEvent>(_handleSignUpWithEmailAndPassword);
    on<SignInWithGoogleEvent>(_handleSignInWithGoogle);
    on<SignInWithFacebookEvent>(_handleSignInWithFacebook);
    on<SignOutEvent>(_handleSignOut);
    on<ForgotPasswordRequested>(_handleForgotPassword);
    on<PasswordResetRequested>(_handlePasswordReset);
  }

  // Connexion email/mot de passe
  Future<void> _handleSignInWithEmailAndPassword(
      SignInWithEmailAndPasswordEvent event,
      Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (!EmailValidator.validate(event.email)) {
        emit(AuthError('Email invalide'));
        return;
      }

      final user = await signInWithEmailAndPassword(event.email, event.password);
      final uid = await authRepository.getUserId();

      if (uid == null) {
        emit(AuthError('Identifiant utilisateur introuvable'));
        return;
      }

      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError('Erreur authentification : ${e.toString()}'));
    }
  }

  // Inscription email/mot de passe
  Future<void> _handleSignUpWithEmailAndPassword(
      SignUpWithEmailAndPasswordEvent event,
      Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (!EmailValidator.validate(event.email)) {
        emit(AuthError('Adresse email invalide'));
        return;
      }

      final user = await signUpWithEmailAndPassword(
        event.email,
        event.password,
        event.firstName,
        event.lastName,
      );

      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError('Cet email est déjà utilisé'));
    }
  }

  // Connexion Google
  Future<void> _handleSignInWithGoogle(
      SignInWithGoogleEvent event,
      Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await signInWithGoogle();
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthError("Échec de connexion Google"));
      }
    } catch (e) {
      String errorMessage = "Échec de connexion Google";
      if (e.toString().contains('sign_in_canceled')) {
        errorMessage = "Vous avez annulé la connexion Google";
      } else if (e.toString().contains('network_error')) {
        errorMessage = "Vérifiez votre connexion Internet";
      }
      emit(AuthError(errorMessage));
    }
  }

  // Connexion Facebook
  Future<void> _handleSignInWithFacebook(
      SignInWithFacebookEvent event,
      Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await signInWithFacebook();
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthError("Échec de connexion Facebook"));
      }
    } catch (e) {
      String errorMessage = "Échec de connexion Facebook";
      if (e.toString().contains('CANCELLED')) {
        errorMessage = "Connexion Facebook annulée";
      } else if (e.toString().contains('NETWORK_ERROR')) {
        errorMessage = "Problème réseau lors de la connexion Facebook";
      }
      emit(AuthError(errorMessage));
    }
  }

  // Déconnexion
  Future<void> _handleSignOut(
      SignOutEvent event,
      Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Mot de passe oublié
  Future<void> _handleForgotPassword(
      ForgotPasswordRequested event,
      Emitter<AuthState> emit) async {
    emit(ForgotPasswordLoading());
    try {
      if (!EmailValidator.validate(event.email)) {
        emit(ForgotPasswordError('Adresse email invalide'));
        return;
      }
      await forgotPasswordUseCase.execute(event.email);
      emit(ForgotPasswordSuccess('Email envoyé avec succès'));
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
    }
  }

  // Réinitialiser mot de passe
  Future<void> _handlePasswordReset(
      PasswordResetRequested event,
      Emitter<AuthState> emit) async {
    emit(ResetPasswordLoading());
    try {
      await resetPasswordUseCase.execute(event.oobCode, event.newPassword);
      emit(ResetPasswordSuccess());
    } catch (e) {
      emit(ResetPasswordError(e.toString()));
    }
  }
}