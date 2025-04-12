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
        Text(
          'Or continue with',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 34),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              onPressed: onGooglePressed,
            ),
            const SizedBox(width: 30),
            _buildSocialButton(
              icon: Icons.facebook,
              onPressed: onFacebookPressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 11,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, size: 28, color: AppColors.primary),
      ),
    );
  }
}