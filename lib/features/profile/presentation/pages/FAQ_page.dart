import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Lottie.asset(
              'assets/animations/fq.json', // Remplacez par votre propre illustration
              height: 150,
            ),
            const SizedBox(height: 30),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ..._buildFAQItems(),
            const SizedBox(height: 30),
            _buildContactCard(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFAQItems() {
    final faqs = [
      {
        'question': 'How can I scan a product?',
        'answer':
        'Tap the scan icon in the navigation bar and point your camera at the product\'s barcode.',
      },
      {
        'question': 'How do I manage my allergy preferences?',
        'answer':
        'Go to your profile, then open the allergy settings. Enable or disable the ingredients you want to avoid.',
      },
      {
        'question': 'Is the app free to use?',
        'answer':
        'Yes, the app is completely free to use. There is no Premium version.',
      },
      {
        'question': 'How can I delete my account?',
        'answer':
        'Go to Settings > Account > Delete Account to permanently remove your profile and all your data.',
      },
      {
        'question': 'Can the app work offline?',
        'answer':
        'No, the app requires an internet connection to function properly.',
      },
      {
        'question': 'How does the receipt scanner work?',
        'answer':
        'You can scan your receipt using your camera. The app will analyze the nutritional content of the listed products and compare their prices with other stores.',
      },
      {
        'question':
        'Will I receive allergy alerts for every scanned or searched product?',
        'answer':
        'Yes, if you have configured your allergy preferences, the app will alert you when a product contains ingredients you\'re allergic to.',
      },
      {
        'question': 'How can I contact support?',
        'answer':
        'You can contact our support team at support@example.com or help@example.com',
      },
      {
        'question': 'How can I change the language or activate dark mode?',
        'answer':
        'Go to Settings > Languages to change the language or switch between light and dark mode.',
      },
      {
        'question': 'How can I add a product to favorites?',
        'answer':
        'Tap the heart icon (like button) next to the product to add it to your favorites list.',
      },
    ];

    return faqs.map((faq) {
      return ExpansionTile(
        title: Text(
          faq['question']!,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            faq['answer']!,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }).toList();
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Need more help?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Contact our support team:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premier contact email
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8), // Espace vertical entre les éléments
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _launchEmail(context, 'mariemanaya20@gmail.com'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding augmenté
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email_rounded,
                            size: 22,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 12), // Espacement augmenté
                          Text(
                            'mariemanaya20@gmail.com',
                            style: TextStyle(
                              fontSize: 15, // Taille de police légèrement augmentée
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500, // Texte un peu plus gras
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Deuxième contact email
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8), // Espace vertical entre les éléments
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _launchEmail(context, 'chaoualihiba25@gmail.com'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding augmenté
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email_rounded,
                            size: 22,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 12), // Espacement augmenté
                          Text(
                            'chaoualihiba25@gmail.com',
                            style: TextStyle(
                              fontSize: 15, // Taille de police légèrement augmentée
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500, // Texte un peu plus gras
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

          ],
        ),
      ),
    );
  }

  void _launchEmail(BuildContext context, String email) async {
    final Uri emailUri = Uri(
      scheme: 'https',
      host: 'mail.google.com',
      path: '/mail/u/0/',
      queryParameters: {
        'view': 'cm',
        'fs': '1',
        'to': email,
        'su': 'Support Request',
        'body': 'Hello, I need help with...',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.inAppWebView);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No email app found on your device.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error launching email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open email app. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}