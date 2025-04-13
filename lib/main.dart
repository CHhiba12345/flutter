import 'package:eye_volve/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'features/auth/data/datasources/auth_service.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/favorites/domain/usecases/add_to_favorites.dart';
import 'features/favorites/domain/usecases/get_favorites.dart';
import 'features/favorites/presentation/bloc/favorite_event.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/history/presentation/bloc/history_event.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'firebase_options.dart';

// Importations des dépendances Auth
import 'features/auth/data/datasources/firebase_auth_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'features/auth/domain/usecases/sign_up_with_email_and_password.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_in_with_facebook.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/forgot_password_use_case.dart';
import 'features/auth/domain/usecases/reset_password_use_case.dart';

// Importations des dépendances Home
import 'features/home/data/datasources/home_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/scan_product.dart';

// Importations des dépendances History
import 'features/history/data/datasources/history_datasource.dart';
import 'features/history/data/repositories/history_repository_impl.dart';
import 'features/history/domain/repositories/history_repository.dart';
import 'features/history/domain/usecases/get_history_usecase.dart';
import 'features/history/domain/usecases/record_history.dart';
import 'features/history/domain/usecases/delete_history_usecase.dart';

// Importations des dépendances Favorites
import 'features/favorites/data/datasources/favorite_datasource.dart';
import 'features/favorites/data/repositories/favorite_repository_impl.dart';
import 'features/favorites/domain/repositories/favorite_repository.dart';
import 'features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'features/favorites/presentation/bloc/favorite_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialisation des dépendances Auth
  final authService = AuthService();
  final authDataSource = FirebaseAuthDataSource();
  final authRepository = AuthRepositoryImpl(authDataSource, authService);

  // Use Cases Auth
  final signInWithEmailAndPassword = SignInWithEmailAndPassword(authRepository);
  final signUpWithEmailAndPassword = SignUpWithEmailAndPassword(authRepository);
  final signInWithGoogle = SignInWithGoogle(authRepository);
  final signInWithFacebook = SignInWithFacebook(authRepository);
  final signOut = SignOut(authRepository);
  final forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
  final resetPasswordUseCase = ResetPasswordUseCase(authRepository);

  // Récupération du token JWT après connexion
  final jwtToken = await authService.getToken() ?? '';

  // Dépendances Home
  final homeDataSource = HomeDataSource(jwtToken: jwtToken);
  final homeRepository = HomeRepositoryImpl(homeDataSource: homeDataSource);
  final scanProductUseCase = ScanProduct(homeRepository);

  // Dépendances History
  final historyDataSource = HistoryDataSource(jwtToken: jwtToken);
  final historyRepository = HistoryRepositoryImpl(dataSource: historyDataSource);
  final recordHistory = RecordHistory(repository: historyRepository);
  final deleteHistoryUseCase = DeleteHistoryUseCase(repository: historyRepository);

  // Dépendances Favorites
  final favoriteDataSource = FavoriteDataSource(jwtToken: jwtToken);
  final favoriteRepository = FavoriteRepositoryImpl(dataSource: favoriteDataSource);
  final toggleFavoriteUseCase = ToggleFavoriteUseCase(favoriteRepository);

  runApp(
    MyApp(
      authRepository: authRepository,
      signInWithEmailAndPassword: signInWithEmailAndPassword,
      signUpWithEmailAndPassword: signUpWithEmailAndPassword,
      signInWithGoogle: signInWithGoogle,
      signInWithFacebook: signInWithFacebook,
      signOut: signOut,
      forgotPasswordUseCase: forgotPasswordUseCase,
      resetPasswordUseCase: resetPasswordUseCase,
      scanProductUseCase: scanProductUseCase,
      recordHistory: recordHistory,
      historyRepository: historyRepository,
      deleteHistoryUseCase: deleteHistoryUseCase,
      toggleFavoriteUseCase: toggleFavoriteUseCase, // Nouveau paramètre
      favoriteRepository: favoriteRepository, // Nouveau paramètre
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final SignInWithEmailAndPassword signInWithEmailAndPassword;
  final SignUpWithEmailAndPassword signUpWithEmailAndPassword;
  final SignInWithGoogle signInWithGoogle;
  final SignInWithFacebook signInWithFacebook;
  final SignOut signOut;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final ScanProduct scanProductUseCase;
  final RecordHistory recordHistory;
  final HistoryRepository historyRepository;
  final DeleteHistoryUseCase deleteHistoryUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase; // Nouveau paramètre
  final FavoriteRepository favoriteRepository; // Nouveau paramètre

  final _appRouter = AppRouter();

  MyApp({
    super.key,
    required this.authRepository,
    required this.signInWithEmailAndPassword,
    required this.signUpWithEmailAndPassword,
    required this.signInWithGoogle,
    required this.signInWithFacebook,
    required this.signOut,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.scanProductUseCase,
    required this.recordHistory,
    required this.historyRepository,
    required this.deleteHistoryUseCase,
    required this.toggleFavoriteUseCase, // Ajout du paramètre
    required this.favoriteRepository, // Ajout du paramètre
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Bloc Auth
        BlocProvider(
          create: (context) => AuthBloc(
            signInWithEmailAndPassword: signInWithEmailAndPassword,
            signUpWithEmailAndPassword: signUpWithEmailAndPassword,
            signInWithGoogle: signInWithGoogle,
            signInWithFacebook: signInWithFacebook,
            signOut: signOut,
            forgotPasswordUseCase: forgotPasswordUseCase,
            resetPasswordUseCase: resetPasswordUseCase,
            authRepository: authRepository,
          ),
        ),

        // Bloc Home
        BlocProvider(
          create: (context) => HomeBloc(
            scanProduct: scanProductUseCase,
            recordHistory: recordHistory,
            toggleFavorite: toggleFavoriteUseCase, // Injection du use case
          ),
        ),

        // Bloc History
        BlocProvider(
          create: (context) => HistoryBloc(
            getHistoryUseCase: GetHistoryUseCase(repository: historyRepository),
            recordHistory: recordHistory,
            deleteHistory: deleteHistoryUseCase,
          )..add(const LoadHistoryEvent()),
        ),

        // Bloc Favorites
        // Bloc Favorites
        Provider<FavoriteRepository>(
          create: (_) => favoriteRepository, // Expose FavoriteRepository ici
        ),
        BlocProvider(
          create: (context) => FavoriteBloc(
            addToFavorites: AddToFavorites(context.read<FavoriteRepository>()),
            getFavorites: GetFavorites(context.read<FavoriteRepository>()),
            removeFromFavorites: RemoveFromFavorites(context.read<FavoriteRepository>()),
          )..add(LoadFavoritesEvent(uid: 'current_user_uid')),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Eye Volve',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routerConfig: _appRouter.config(),
      ),
    );
  }
}