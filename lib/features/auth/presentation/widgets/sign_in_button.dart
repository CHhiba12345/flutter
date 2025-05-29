import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../blocs/auth_state.dart';

/// Bouton personnalisé pour la connexion
///
/// Affiche un indicateur de chargement si l'état est [AuthState.loading]
class SignInButton extends StatelessWidget {
  final AuthState state;
  final VoidCallback onPressed;

  const SignInButton({
    Key? key,
    required this.state,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          /// Désactive le bouton en mode chargement
          onPressed: state is AuthLoading ? null : onPressed,

          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),

          /// Affiche un loader ou le texte du bouton
          child: state is AuthLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
            'Sign In',
            style: AppTextStyles.button?.copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }
}