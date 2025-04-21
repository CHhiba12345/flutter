import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../app_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> sections = [
    {
      "title": "Welcome to FooDScan!",
      "subtitle": "Scan or Search Products",
      "description":
      "Quickly scan a barcode or search manually to get detailed info: ingredients, allergens, additives, Nutri-Score, and more. Make smarter choices in seconds.",
      "lottieAsset": "assets/animations/s.json",
      "bgColors": [Color(0xFFDCD2C5), Color(0xFF6BFFEE), Color(0xFF38468E)],
    },
    {
      "title": "Customize Based on Your Preferences",
      "subtitle": "Personalized Alerts",
      "description":
      "Set your dietary preferences in seconds. Whether you have allergies (milk, gluten, peanuts…) or follow a specific diet (vegetarian, vegan…), the app will automatically alert you.",
      "lottieAsset": "assets/animations/s2.json",
      "bgColors": [Color(0xFFDCD2C5), Color(0xFF6BFFEE), Color(0xFF38468E)],
    },
    {
      "title": "Analyze Your Grocery Receipts",
      "subtitle": "Smart Insights",
      "description":
      "Take a photo of your receipt and let the app analyze all purchased products. Get a full overview of the nutritional quality of your purchases.",
      "lottieAsset": "assets/animations/sss.json",
      "buttonText": "Get Started",
      "bgColors": [Color(0xFFDCD2C5), Color(0xFF6BFFEE), Color(0xFF38468E)],
    },
  ];

  void _skipOnboarding() {
    context.router.replace(const SignUpRoute());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: sections.length,
              physics: const ClampingScrollPhysics(), // 🔁 Scroll plus fluide
              pageSnapping: true, // ✅ Pour que le changement de page soit net
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final section = sections[index];
                final bgColors = section["bgColors"] as List<Color>;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: constraints.maxHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: bgColors,
                          stops: _generateStops(bgColors.length),
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              SizedBox(
                                height: size.height * 0.4,
                                child: Center(
                                  child: Lottie.asset(
                                    section["lottieAsset"],
                                    fit: BoxFit.contain,
                                    width: size.width * 0.8,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      section["title"],
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 28,
                                      ),
                                      textAlign: TextAlign.center,
                                    ).animate().fadeIn(duration: 500.ms),
                                    const SizedBox(height: 12),
                                    if (section["subtitle"]
                                        .toString()
                                        .isNotEmpty)
                                      Text(
                                        section["subtitle"],
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color:
                                          Colors.white.withOpacity(0.9),
                                        ),
                                        textAlign: TextAlign.center,
                                      ).animate().fadeIn(delay: 300.ms),
                                    const SizedBox(height: 16),
                                    Text(
                                      section["description"],
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                        color:
                                        Colors.white.withOpacity(0.85),
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ).animate().fadeIn(delay: 600.ms),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (index == sections.length - 1)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: bgColors[0],
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 40, vertical: 16),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(30)),
                                          elevation: 5,
                                          shadowColor: Colors.black26,
                                        ),
                                        onPressed: _skipOnboarding,
                                        child: Text(
                                          section['buttonText'] ??
                                              'Get Started',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ).animate().slideY(
                                          begin: 0.5,
                                          end: 0,
                                          delay: 900.ms,
                                          duration: 600.ms),
                                      const SizedBox(height: 20),
                                      _buildProgressIndicator(),
                                    ],
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: _buildProgressIndicator(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _skipOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _generateStops(int length) {
    switch (length) {
      case 2:
        return [0.0, 1.0];
      case 3:
        return [0.0, 0.5, 1.0];
      default:
        return [0.0, 1.0];
    }
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        sections.length,
            (index) => AnimatedContainer(
          duration: 300.ms,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
