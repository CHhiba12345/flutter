import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PremiumTermsPage extends StatelessWidget {
  const PremiumTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Future Premium Features',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Animation Lottie
            Lottie.asset(
              'assets/animations/pr.json', // Vérifiez que ce chemin est correct
              height: 120,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 20),

            // Current Status Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.green.withOpacity(0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.celebration, size: 40, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      'Current App Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'All features are currently completely free with no limitations. Enjoy full access to all functionality!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Future Features Title
            const Text(
              'Potential Future Enhancements',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'We may introduce premium features in the future to support development',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Feature List
            _buildFeatureCard(
              icon: Icons.insights,
              title: 'Advanced Analytics',
              description: 'Detailed nutritional reports and long-term trend analysis',
              color: Colors.blue,
            ),
            _buildFeatureCard(
              icon: Icons.receipt_long,
              title: 'Unlimited Receipt Storage',
              description: 'Save and compare all your shopping history',
              color: Colors.purple,
            ),
            _buildFeatureCard(
              icon: Icons.health_and_safety,
              title: 'Professional Allergy Advisor',
              description: 'Personalized recommendations from nutrition experts',
              color: Colors.red,
            ),
            _buildFeatureCard(
              icon: Icons.store,
              title: 'Price Alert System',
              description: 'Get notifications when favorite products go on sale',
              color: Colors.orange,
            ),

            const SizedBox(height: 32),

            // Commitment
            const Text(
              'Our Commitment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Any future premium features will be clearly communicated in advance. '
                    'Current core functionality will always remain free. We believe in transparent pricing and no surprises.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // Contact
            const Text(
              'Have suggestions?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () {
                // Naviguer vers la page de contact
              },
              child: const Text('Contact our team'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}