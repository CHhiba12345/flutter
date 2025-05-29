import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

/// Section d'authentification sociale (Google / Facebook)
///
/// Affiche une ligne de séparation avec l'option "Or continue with",
/// suivie par les boutons de connexion sociale.
class SocialLoginSection extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onFacebookPressed;

  const SocialLoginSection({
    Key? key,
    required this.onGooglePressed,
    required this.onFacebookPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ligne de séparation + texte "Or continue with"
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: Colors.white38,
                thickness: 1,
                endIndent: 8,
              ),
            ),
            Text(
              'Or continue with',
              style: AppTextStyles.bodyMedium?.copyWith(
                color: AppColors.backgroundLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Expanded(
              child: Divider(
                color: Colors.white38,
                thickness: 1,
                indent: 8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Boutons Google & Facebook
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircularSocialButton(
              icon: Icons.g_mobiledata_rounded,
              onPressed: onGooglePressed,
              backgroundColor: Colors.white,
              iconColor: Colors.black,
              borderColor: Colors.white,
            ),
            const SizedBox(width: 16),
            _buildCircularSocialButton(
              icon: Icons.facebook,
              onPressed: onFacebookPressed,
              backgroundColor: Color(0xFFF6FAF8),
              iconColor: Color(0xFF1D7A29),
              borderColor: Color(0xFFEAF4EB),
            ),
          ],
        ),
      ],
    );
  }

  /// Bouton rond pour la connexion sociale
  Widget _buildCircularSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
    required Color borderColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const CircleBorder(
          side: BorderSide(width: 1.5),
        ),
        side: BorderSide(color: borderColor, width: 1.5),
        padding: const EdgeInsets.all(16),
        elevation: 0,
      ),
      child: Icon(icon, size: 24, color: iconColor),
    );
  }
}