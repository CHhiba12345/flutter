import 'package:eye_volve/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'app_router.dart';

// Importations des dépendances Auth
import 'features/auth/data/datasources/auth_service.dart';
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
import 'features/auth/presentation/blocs/auth_bloc.dart';

// Importations des dépendances Home
import 'features/favorites/presentation/bloc/favorite_event.dart';
import 'features/history/presentation/bloc/history_event.dart';
import 'features/home/data/datasources/home_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/scan_product.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

// Importations des dépendances History
import 'features/history/data/datasources/history_datasource.dart';
import 'features/history/data/repositories/history_repository_impl.dart';
import 'features/history/domain/repositories/history_repository.dart';
import 'features/history/domain/usecases/get_history_usecase.dart';
import 'features/history/domain/usecases/record_history.dart';
import 'features/history/domain/usecases/delete_history_usecase.dart';
import 'features/history/presentation/bloc/history_bloc.dart';

// Importations des dépendances Favorites
import 'features/favorites/data/datasources/favorite_datasource.dart';
import 'features/favorites/data/repositories/favorite_repository_impl.dart';
import 'features/favorites/domain/repositories/favorite_repository.dart';
import 'features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'features/favorites/domain/usecases/add_to_favorites.dart';
import 'features/favorites/domain/usecases/get_favorites.dart';
import 'features/favorites/presentation/bloc/favorite_bloc.dart';

// Importations des dépendances Profile
import 'features/profile/data/datasources/profile_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/clear_user_allergens.dart';
import 'features/profile/domain/usecases/get_user_allergens.dart';
import 'features/profile/domain/usecases/set_user_allergens.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'firebase_options.dart';

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
  final homeDataSource = HomeDataSource();
  final homeRepository = HomeRepositoryImpl(homeDataSource: homeDataSource);
  final scanProductUseCase = ScanProduct(homeRepository);

  // Dépendances History
  final historyDataSource = HistoryDataSource();
  final historyRepository = HistoryRepositoryImpl(dataSource: historyDataSource);
  final recordHistory = RecordHistory(repository: historyRepository);
  final deleteHistoryUseCase = DeleteHistoryUseCase(repository: historyRepository);

  // Dépendances Favorites
  final favoriteDataSource = FavoriteDataSource();
  final favoriteRepository = FavoriteRepositoryImpl(dataSource: favoriteDataSource);
  final toggleFavoriteUseCase = ToggleFavoriteUseCase(favoriteRepository);

  // Dépendances Profile
  final profileDataSource = ProfileDataSourceImpl(
    client: http.Client(),
    authService: authService,
  );
  final profileRepository = ProfileRepositoryImpl(dataSource: profileDataSource);
  final getUserAllergensUseCase = GetUserAllergens(profileRepository);
  final setUserAllergensUseCase = SetUserAllergens(profileRepository);
  final clearUserAllergensUseCase = ClearUserAllergens(profileRepository);

  // Récupération de l'ID utilisateur connecté
  final userId = await authService.getCurrentUserId() ?? '';

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
      toggleFavoriteUseCase: toggleFavoriteUseCase,
      favoriteRepository: favoriteRepository,
      initialUid: userId, // Passez l'ID utilisateur dynamique
      getUserAllergensUseCase: getUserAllergensUseCase,
      setUserAllergensUseCase: setUserAllergensUseCase,
      clearUserAllergensUseCase: clearUserAllergensUseCase,
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
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final FavoriteRepository favoriteRepository;

  final GetUserAllergens getUserAllergensUseCase;
  final SetUserAllergens setUserAllergensUseCase;
  final ClearUserAllergens clearUserAllergensUseCase;

  final String initialUid; // Ajout de l'ID utilisateur
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
    required this.toggleFavoriteUseCase,
    required this.favoriteRepository,
    required this.initialUid, // Ajout du paramètre
    required this.getUserAllergensUseCase,
    required this.setUserAllergensUseCase,
    required this.clearUserAllergensUseCase,
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
            toggleFavorite: toggleFavoriteUseCase,
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
        BlocProvider(
          create: (context) => FavoriteBloc(
            addToFavorites: AddToFavorites(favoriteRepository),
            getFavorites: GetFavorites(favoriteRepository),
            removeFromFavorites: RemoveFromFavorites(favoriteRepository),
          )..add(LoadFavoritesEvent(uid: initialUid)),
        ),

        // Bloc Profile
        BlocProvider(
          create: (context) => ProfileBloc(
            getUserAllergens: getUserAllergensUseCase,
            setUserAllergens: setUserAllergensUseCase,
            clearUserAllergens: clearUserAllergensUseCase, authService: AuthService(),
          ),
        ),
      ],
      child: MultiProvider(
        providers: [
          Provider<FavoriteRepository>(create: (_) => favoriteRepository), // Ajout du provider
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
      ),
    );
  }
}