import 'package:flutter/material.dart';
import '../../../../app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import 'package:auto_route/auto_route.dart';

class AuthForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback togglePasswordVisibility;
  final GlobalKey<FormState> formKey;

  // Gestion des erreurs personnalisées
  final bool showErrors;
  final String? emailError;
  final String? passwordError;

  const AuthForm({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.togglePasswordVisibility,
    required this.formKey,
    required this.showErrors,
    this.emailError,
    this.passwordError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Champ Email
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmailField(),
            if (showErrors && emailError != null)
              _buildErrorText(emailError!),
          ],
        ),

        const SizedBox(height: 20),

        // Champ Mot de passe
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField(),
            if (showErrors && passwordError != null)
              _buildErrorText(passwordError!),
          ],
        ),

        const SizedBox(height: 2),
        // Lien "Mot de passe oublié"
        _buildForgotPassword(context),
      ],
    );
  }

  // === Champs de formulaire ===

  /// Champ d'email
  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: false,
          errorStyle: TextStyle(height: 0), // Cache l'erreur standard
        ),
        validator: _validateEmail,
      ),
    );
  }

  /// Champ de mot de passe
  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: TextFormField(
        controller: passwordController,
        obscureText: obscurePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
            color: AppColors.primary,
            onPressed: togglePasswordVisibility,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: false,
          errorStyle: TextStyle(height: 0), // Cache l'erreur standard
        ),
        validator: _validatePassword,
      ),
    );
  }

  // === UI Helpers ===

  /// Affiche un message d'erreur personnalisé sous le champ
  Widget _buildErrorText(String errorText) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Text(
        errorText,
        style: TextStyle(
          color: AppColors.error,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Bouton "Mot de passe oublié"
  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => context.router.push(ForgotPasswordRoute()),
        child: Text(
          'Forgot Password?',
          style: AppTextStyles.bodyMedium?.copyWith(color: AppColors.background),
        ),
      ),
    );
  }

  // === Validations ===

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}