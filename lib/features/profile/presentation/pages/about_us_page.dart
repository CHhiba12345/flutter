import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Animation Lottie
            Lottie.asset(
              'assets/animations/ab.json', // Remplacez par votre animation
              height: 200,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 30),

            // Titre
            const Text(
              'Making Food Choices Smarter & Safer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Carte de mission
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.medical_services, size: 40, color: Colors.green),
                    const SizedBox(height: 15),
                    const Text(
                      'Our Mission',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Empowering you to make informed food choices by providing instant access to nutritional insights and allergen alerts.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Features
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _buildFeatureTile(
              icon: Icons.scanner,
              title: 'Product Scanning',
              subtitle: 'Get instant nutritional info by scanning barcodes',
              color: Colors.blue,
            ),

            _buildFeatureTile(
              icon: Icons.health_and_safety,
              title: 'Allergy Alerts',
              subtitle: 'Personalized alerts for your specific allergens',
              color: Colors.red,
            ),

            _buildFeatureTile(
              icon: Icons.receipt_long,
              title: 'Receipt Analysis',
              subtitle: 'Full nutritional breakdown of your shopping',
              color: Colors.orange,
            ),

            _buildFeatureTile(
              icon: Icons.score,
              title: 'Nutri & Eco Scores',
              subtitle: 'Understand product health and environmental impact',
              color: Colors.green,
            ),

            const SizedBox(height: 30),

            // Team Info
            const Text(
              'Why Choose Us?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Our team of nutritionists and tech experts have created this app to bridge the gap between consumers and food information. We believe everyone deserves transparency about what they eat.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

            // Bouton Contact

          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}