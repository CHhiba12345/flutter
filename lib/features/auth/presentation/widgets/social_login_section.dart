import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

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
              style: AppTextStyles.bodyMedium.copyWith(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata_rounded,
              label: 'Google',
              onPressed: onGooglePressed,
              backgroundColor: Colors.white,
              borderColor: Colors.white,
              iconColor: Colors.black,
              textColor: Colors.black,
            ),
            const SizedBox(width: 16),
            _buildSocialButton(
              icon: Icons.facebook,
              label: 'Facebook',
              onPressed: onFacebookPressed,
              backgroundColor: Color(0xFF1877F2),
              borderColor: Color(0xFF1877F2),
              iconColor: Colors.white,
              textColor: Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: borderColor,
            width: 1.5,
          ),
        ),
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        minimumSize: const Size(100, 50),
      ),
      icon: Icon(
        icon,
        size: 20,
        color: iconColor,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}