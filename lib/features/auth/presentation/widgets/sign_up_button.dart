import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../blocs/auth_state.dart';

/// Bouton personnalisé pour l'inscription
///
/// Affiche un indicateur de chargement si l'état est [AuthState.loading]
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
          /// Désactive le bouton pendant le chargement
          onPressed: state is AuthLoading ? null : onPressed,

          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),

          /// Affiche un loader ou le texte du bouton
          child: state is AuthLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
            'Sign Up',
            style: AppTextStyles.button?.copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }
}