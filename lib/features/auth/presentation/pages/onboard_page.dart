import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../../../../app_router.dart';

@RoutePage()
class OnboardPage extends StatelessWidget {
  const OnboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF20CBEF), // Bleu nuit intense
              Color(0xFF2167AA), // Bleu profond classique
              Color(0xFF6CD3C7), // Bleu clair lumineux
              Color(0xFF264E6C), // Presque blanc, bleu très pâle (ciel)
            ],
            stops: [0.0, 0.4, 0.75, 1.0],

          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              // Lottie animation
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Lottie.asset(
                    "assets/animations/s2.json", // <-- Change to your 2nd screen animation
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Text content
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Customize Based on Your Preferences",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms),
                      ),

                      const SizedBox(height: 14),

                      Flexible(
                        child: Text(
                          "Set your dietary preferences in seconds. Whether you have allergies (milk, gluten, peanuts…) or follow a specific diet (vegetarian, vegan…), the app will automatically alert you if a product contains ingredients to avoid.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 500.ms),
                      ),
                    ],
                  ),
                ),
              ),

              // Button
              Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 40.0),
                child: GestureDetector(
                  onTap: () {
                     context.pushRoute(const OnboRoute());
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7AC1FA), // Bleu clair rafraîchissant
                          Color(0xFF348EEA), // Bleu vif (point central)
                          Color(0xFF69D4D6), // Bleu foncé profond
                        ],
                        stops: [0.11, 0.40, 0.75],

                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
