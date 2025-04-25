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
          side: BorderSide(
            width: 1.5,
          ),
        ),
        side: BorderSide(color: borderColor, width: 1.5),
        padding: const EdgeInsets.all(16),
        elevation: 0,
      ),
      child: Icon(
        icon,
        size: 24,
        color: iconColor,
      ),
    );
  }
}
