import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../blocs/auth_state.dart';

class SignUpButton extends StatelessWidget {
  final AuthState state;
  final VoidCallback onPressed;

  const SignUpButton({
    Key? key,
    required this.state,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
        width: 300,
        height: 60,
      child: ElevatedButton(
        onPressed: state is AuthLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: state is AuthLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          'Sign Up',
          style: AppTextStyles.button.copyWith(color: Colors.white),
        ),
      ),
        )
    );
  }
}