
import 'package:eye_volve/features/favorites/domain/usecases/remove_from_favorites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
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
import 'features/auth/presentation/blocs/auth_state.dart';

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
import 'features/ticket/data/datasources/receipt_scanner_service.dart';
import 'features/ticket/domain/usecases/get_price_comparisons_usecase.dart';
import 'firebase_options.dart';

////////////////////
import 'features/ticket/data/datasources/ticket_datasource.dart';
import 'features/ticket/data/repositories/ticket_repository_impl.dart';
import 'features/ticket/domain/repositories/ticket_repository.dart';
import 'features/ticket/domain/usecases/send_ticket_usecase.dart';
import 'features/ticket/presentation/bloc/ticket_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


// Initialiser Hive
  //await Hive.initFlutter();

  // Enregistrer les adaptateurs
 // Hive.registerAdapter(ChatMessageAdapter());

  // Ouvrir toutes les boîtes nécessaires
  //final chatBox = await Hive.openBox<ChatMessage>('chat_messages');
  //final sessionBox = await Hive.openBox<String>('user_sessions'); // Boîte pour les sessions

  //print('🔴 Nombre initial de messages dans Hive: ${chatBox.length}');
 // print('🟢 Boîte de sessions initialisée');
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
  print('🟢 User ID exact: $userId');

  // Dépendances Ticket
  final ticketDataSource = TicketDataSource(authService);
  final ticketRepository = TicketRepositoryImpl(
    dataSource: ticketDataSource,
    authService: authService,
  );
  final sendTicketUseCase = SendTicketUseCase(repository: ticketRepository);
  final getPriceComparisonsUseCase = GetPriceComparisonsUseCase(repository: ticketRepository);
  final scannerService = ReceiptScannerService();


  // Chatbot initialization
  /* final chatbotDataSource = ChatBotRemoteDataSourceImpl(client: http.Client());
  final chatbotRepository = ChatbotRepositoryImpl(
    remoteDataSource: chatbotDataSource,
    chatBox: chatBox,
    sessionBox: sessionBox,
  );
  final sendQuestionUseCase = SendQuestionUsecase(chatbotRepository);
  final sessionId = await chatbotRepository.getOrCreateSession(userId);
*/
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
      initialUid: userId,
      getUserAllergensUseCase: getUserAllergensUseCase,
      setUserAllergensUseCase: setUserAllergensUseCase,
      clearUserAllergensUseCase: clearUserAllergensUseCase,
      sendTicketUseCase: sendTicketUseCase,
      scannerService: scannerService,
      getPriceComparisonsUseCase: getPriceComparisonsUseCase,
      //sendQuestionUseCase: sendQuestionUseCase,
     // chatBox: chatBox,
     // initialSessionId: sessionId,
     // sessionBox: sessionBox,

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
  final SendTicketUseCase sendTicketUseCase;
  final GetPriceComparisonsUseCase getPriceComparisonsUseCase;
  final String initialUid;
  final ReceiptScannerService scannerService;
 // final  SendQuestionUsecase sendQuestionUseCase;
 // final Box<ChatMessage> chatBox;
  //final String initialSessionId;
 // final Box<String> sessionBox;

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
    required this.initialUid,
    required this.getUserAllergensUseCase,
    required this.setUserAllergensUseCase,
    required this.clearUserAllergensUseCase,
    required this.sendTicketUseCase,
    required this.scannerService,
    required this.getPriceComparisonsUseCase,
    /* required this.sendQuestionUseCase,
    required this.chatBox,
    required this.initialSessionId,
    required this.sessionBox, */

  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
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
        BlocProvider(
          create: (context) => HomeBloc(
            scanProduct: scanProductUseCase,
            recordHistory: recordHistory,
            toggleFavorite: toggleFavoriteUseCase,
          ),
        ),
        BlocProvider(
          create: (context) => HistoryBloc(
            getHistoryUseCase: GetHistoryUseCase(repository: historyRepository),
            recordHistory: recordHistory,
            deleteHistory: deleteHistoryUseCase,
          )..add(const LoadHistoryEvent()),
        ),
        BlocProvider(
          create: (context) => FavoriteBloc(
            addToFavorites: AddToFavorites(favoriteRepository),
            getFavorites: GetFavorites(favoriteRepository),
            removeFromFavorites: RemoveFromFavorites(favoriteRepository),
          )..add(LoadFavoritesEvent(uid: initialUid)),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(
            getUserAllergens: getUserAllergensUseCase,
            setUserAllergens: setUserAllergensUseCase,
            clearUserAllergens: clearUserAllergensUseCase,
            authService: AuthService(),
          ),
        ),
        BlocProvider(
          create: (context) => TicketBloc(
            sendTicketUseCase: sendTicketUseCase,
            scannerService: scannerService,
            getPriceComparisonsUseCase: getPriceComparisonsUseCase,
          ),
        ),
      /*  BlocProvider(
          create: (context) => ChatbotBloc(
            usecase: sendQuestionUseCase,
            chatBox: chatBox,
            currentUserId: initialUid,
            currentSessionId: initialSessionId,// Utilisez la sessionId obtenue plus tôt
          ),
        ), */
      ],
      child: MultiProvider(
        providers: [
          Provider<FavoriteRepository>(create: (_) => favoriteRepository),
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