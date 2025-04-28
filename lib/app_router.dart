import 'package:auto_route/auto_route.dart';
import 'package:eye_volve/features/auth/presentation/pages/onboarding_Page.dart';
import 'package:eye_volve/features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/ForgotPasswordPage.dart';
import 'features/auth/presentation/pages/ResetPasswordPage.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'features/auth/presentation/pages/sign_up_page.dart';
import 'features/favorites/presentation/pages/favorites_page.dart';
import 'features/history/presentation/pages/history_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/allergens_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/ticket/presentation/pages/ticket_page.dart';
import 'main_layout_page.dart';
import 'package:flutter/material.dart'; // Assurez-vous que cet import est présent


part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    // Route initiale vers Splash
    AutoRoute(page: SplashRoute.page, initial: true),

    // Routes d'authentification
    AutoRoute(page: SignInRoute.page),
    AutoRoute(page: SignUpRoute.page),
    AutoRoute(page: ForgotPasswordRoute.page),
    CustomRoute(
      page: ResetPasswordRoute.page,
      path: '/reset-password',
      transitionsBuilder: TransitionsBuilders.fadeIn,
      durationInMilliseconds: 800,
    ),
    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: AllergensRoute.page),
    AutoRoute(page: FavoritesRoute.page),
    //Allergens
    // Route principale avec sous-routes
    AutoRoute(
      path: '/main',
      page: MainLayoutRoute.page,
      children: [
        AutoRoute(path: 'home', page: HomeRoute.page, initial: true),
        AutoRoute(path: 'history', page: HistoryRoute.page),
        AutoRoute(path: 'profile', page: ProfileRoute.page),
        AutoRoute(path: 'ticket', page: TicketRoute.page),
      ],
    ),
  ];
}