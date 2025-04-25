import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eye_volve/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:eye_volve/features/auth/presentation/blocs/auth_state.dart';
import 'package:eye_volve/app_router.dart';
import 'package:lottie/lottie.dart';

import '../../data/datasources/auth_service.dart';
@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authService = AuthService();
    final isLoggedIn = await authService.isUserLoggedIn();

    // Attendre un minimum de 2 secondes pour l'animation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (isLoggedIn) {
        // Mettre à jour le token et naviguer
        await authService.updateToken();
        context.router.replace(const MainLayoutRoute());
      } else {
        // Naviguer vers onboarding
        context.router.replace(const OnboardingRoute());
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Lottie.asset(
          'assets/animations/splash.json',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}