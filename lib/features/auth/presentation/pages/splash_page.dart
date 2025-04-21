import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eye_volve/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:eye_volve/features/auth/presentation/blocs/auth_state.dart';
import 'package:eye_volve/app_router.dart';
import 'package:lottie/lottie.dart';

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

    // Attendre 6 secondes avant de rediriger
    Future.delayed(const Duration(seconds: 6), () {
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthSuccess) {
        context.router.replace(const HomeRoute()); // Redirection vers la page d'accueil
      } else {
        context.router.replace(OnboardingRoute()); // Redirection vers la page de connexion
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond noir
      body: SizedBox.expand(
        child: Lottie.asset(
          'assets/animations/splash.json', // Animation Lottie
          fit: BoxFit.cover, // Pour remplir tout l'écran
        ),
      ),
    );
  }
}
