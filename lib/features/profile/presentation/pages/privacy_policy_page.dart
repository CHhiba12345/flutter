import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Privacy Matters',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This Privacy Policy explains how we collect, use, and protect your personal information when you use our application.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Section 1
            _buildSectionHeader('1. Information We Collect'),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.person,
              title: 'Personal Information',
              content:
              'When you create a profile, we may collect personal data such as your name, email, and preferences (e.g., allergies).',
              color: Colors.blue,
            ),
            _buildInfoCard(
              icon: Icons.search,
              title: 'Product Searches & Scans',
              content:
              'We store scanned or searched product data to improve your experience and provide personalized feedback.',
              color: Colors.green,
            ),
            _buildInfoCard(
              icon: Icons.health_and_safety,
              title: 'Allergy Information',
              content:
              'If you choose to set your allergy preferences, this data is stored securely to provide real-time alerts.',
              color: Colors.red,
            ),
            _buildInfoCard(
              icon: Icons.receipt,
              title: 'Receipts & Purchase Data',
              content:
              'When you scan receipts, we extract product names and prices to analyze nutritional data and offer price comparisons.',
              color: Colors.orange,
            ),
            _buildInfoCard(
              icon: Icons.phone_android,
              title: 'Device & Usage Data',
              content:
              'We may collect anonymous technical data (device type, app version, usage patterns) to improve app performance.',
              color: Colors.purple,
            ),
            const SizedBox(height: 32),

            // Section 2
            _buildSectionHeader('2. How We Use Your Information'),
            const SizedBox(height: 16),
            _buildBulletPoint('Provide personalized nutritional information and allergy alerts'),
            _buildBulletPoint('Analyze your receipts and help track your food choices'),
            _buildBulletPoint('Compare prices for informed purchasing decisions'),
            _buildBulletPoint('Enhance and improve app functionality'),
            const SizedBox(height: 32),

            // Section 3
            _buildSectionHeader('3. Data Sharing'),
            const SizedBox(height: 16),
            const Text(
              'We do not sell or share your personal data with third parties. Your data is only used within the application for the purposes listed above.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Section 4
            _buildSectionHeader('4. Data Security'),
            const SizedBox(height: 16),
            const Text(
              'We implement appropriate technical and organizational measures to protect your personal data from unauthorized access, loss, or misuse.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Section 5
            _buildSectionHeader('5. Your Choices'),
            const SizedBox(height: 16),
            const Text(
              'You can update or delete your profile and allergy preferences at any time in the app settings. You can also request the deletion of all your data by contacting us.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Section 6
            _buildSectionHeader('6. Contact Us'),
            const SizedBox(height: 16),
            const Text(
              'If you have any questions or concerns about this Privacy Policy:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              icon: Icons.email,
              contact: 'mariemanaya20@gmail.com',
              onTap: () => _launchEmail('mariemanaya20@gmail.com'),
            ),
            _buildContactOption(
              icon: Icons.email,
              contact: 'hibachaouali25@gmail.com',
              onTap: () => _launchEmail('hibachaouali25@gmail.com'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.cyan,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.5,
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

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.circle, size: 8),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String contact,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(contact),
      minLeadingWidth: 0,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  static Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }
}