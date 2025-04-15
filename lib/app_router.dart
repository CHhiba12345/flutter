import 'package:auto_route/auto_route.dart';
import 'package:eye_volve/features/auth/presentation/pages/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'features/auth/presentation/pages/ForgotPasswordPage.dart';
import 'features/auth/presentation/pages/ResetPasswordPage.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'features/auth/presentation/pages/sign_up_page.dart';
import 'features/favorites/presentation/pages/favorites_page.dart';
import 'features/history/presentation/pages/history_page.dart';
import 'features/home/presentation/pages/home_page.dart';


part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: SignInRoute.page),
    AutoRoute(page: HistoryRoute.page),
   ///////////////////
    CustomRoute(
      page: FavoritesRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      durationInMilliseconds: 800,
      path: '/favorites/:uid', // Ajoutez un paramètre uid dans le chemin
    ),

    // Nouvelle route pour le mot de passe oublié
    AutoRoute(page: ForgotPasswordRoute.page),

    // Route pour la réinitialisation avec gestion des paramètres
    CustomRoute(
      page: ResetPasswordRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      durationInMilliseconds: 800,
      path: '/reset-password', // Chemin personnalisé pour les liens profonds
    ),

    // Route existante pour l'inscription
    CustomRoute(
      page: SignUpRoute.page,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      durationInMilliseconds: 800,
    ),
  ];
}