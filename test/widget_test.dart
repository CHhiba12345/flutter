import 'package:eye_volve/features/auth/domain/repositories/auth_repository.dart';
import 'package:eye_volve/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:eye_volve/features/auth/domain/usecases/reset_password_use_case.dart';
import 'package:eye_volve/features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:eye_volve/features/auth/domain/usecases/sign_in_with_facebook.dart';
import 'package:eye_volve/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:eye_volve/features/auth/domain/usecases/sign_out.dart';
import 'package:eye_volve/features/auth/domain/usecases/sign_up_with_email_and_password.dart';
import 'package:eye_volve/features/history/domain/repositories/history_repository.dart';
import 'package:eye_volve/features/history/domain/usecases/record_history.dart';
import 'package:eye_volve/features/history/domain/usecases/delete_history_usecase.dart';
import 'package:eye_volve/features/home/domain/usecases/scan_product.dart';
import 'package:eye_volve/features/favorites/domain/repositories/favorite_repository.dart'; // Import ajouté
import 'package:eye_volve/features/favorites/domain/usecases/toggle_favorite_usecase.dart'; // Import ajouté
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eye_volve/main.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Annotation pour générer les mocks nécessaires
@GenerateMocks([
  AuthRepository,
  SignInWithEmailAndPassword,
  SignUpWithEmailAndPassword,
  SignInWithGoogle,
  SignInWithFacebook,
  SignOut,
  ForgotPasswordUseCase,
  ResetPasswordUseCase,
  ScanProduct,
  RecordHistory,
  HistoryRepository,
  DeleteHistoryUseCase,
  FavoriteRepository, // Ajout du mock pour FavoriteRepository
  ToggleFavoriteUseCase, // Ajout du mock pour ToggleFavoriteUseCase
])
import 'widget_test.mocks.dart'; // Fichier à générer

void main() {
  testWidgets('Test d\'affichage initial', (WidgetTester tester) async {
    // Initialisation des mocks
    final mockAuthRepository = MockAuthRepository();
    final mockSignInWithEmail = MockSignInWithEmailAndPassword();
    final mockSignUpWithEmail = MockSignUpWithEmailAndPassword();
    final mockSignInWithGoogle = MockSignInWithGoogle();
    final mockSignInWithFacebook = MockSignInWithFacebook();
    final mockSignOut = MockSignOut();
    final mockForgotPassword = MockForgotPasswordUseCase();
    final mockResetPassword = MockResetPasswordUseCase();
    final mockScanProduct = MockScanProduct();
    final mockRecordHistory = MockRecordHistory();
    final mockHistoryRepository = MockHistoryRepository();
    final mockDeleteHistoryUseCase = MockDeleteHistoryUseCase();
    final mockFavoriteRepository = MockFavoriteRepository(); // Nouveau mock
    final mockToggleFavoriteUseCase = MockToggleFavoriteUseCase(); // Nouveau mock

    // Instanciation de MyApp avec tous les paramètres requis
    await tester.pumpWidget(MyApp(
      authRepository: mockAuthRepository,
      signInWithEmailAndPassword: mockSignInWithEmail,
      signUpWithEmailAndPassword: mockSignUpWithEmail,
      signInWithGoogle: mockSignInWithGoogle,
      signInWithFacebook: mockSignInWithFacebook,
      signOut: mockSignOut,
      forgotPasswordUseCase: mockForgotPassword,
      resetPasswordUseCase: mockResetPassword,
      scanProductUseCase: mockScanProduct,
      recordHistory: mockRecordHistory,
      historyRepository: mockHistoryRepository,
      deleteHistoryUseCase: mockDeleteHistoryUseCase,
      favoriteRepository: mockFavoriteRepository, // Injection du nouveau paramètre
      toggleFavoriteUseCase: mockToggleFavoriteUseCase, // Injection du nouveau paramètre
    ));

    // Attendre que l'application soit entièrement construite
    await tester.pumpAndSettle();

    // Vérification que le widget MaterialApp est affiché
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}