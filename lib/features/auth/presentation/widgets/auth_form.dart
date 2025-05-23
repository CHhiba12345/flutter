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
  final bool showErrors; // Nouveau paramètre
  final String? emailError; // Nouveau paramètre
  final String? passwordError; // Nouveau paramètre

  const AuthForm({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.togglePasswordVisibility,
    required this.formKey,
    required this.showErrors, // Ajouté
    this.emailError, // Ajouté
    this.passwordError, // Ajouté
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmailField(),
            if (showErrors && emailError != null) _buildErrorText(emailError!),
          ],
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField(),
            if (showErrors && passwordError != null) _buildErrorText(passwordError!),
          ],
        ),
        const SizedBox(height: 2),
        _buildForgotPassword(context),
      ],
    );
  }

  Widget _buildErrorText(String? errorText) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Text(
        errorText ?? '',
        style: TextStyle(
          color: AppColors.error,
          fontSize: 12,
        ),
      ),
    );
  }

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
          errorStyle: TextStyle(height: 0), // Cache le texte d'erreur par défaut
        ),
        validator: _validateEmail,
      ),
    );
  }

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
            icon: Icon(
              obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.primary,
            ),
            onPressed: togglePasswordVisibility,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: false,
          errorStyle: TextStyle(height: 0), // Cache le texte d'erreur par défaut
        ),
        validator: _validatePassword,
      ),
    );
  }

  // Passer le context ici pour la navigation
  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Utilisation du context pour naviguer vers la page de mot de passe oublié
          context.router.push(ForgotPasswordRoute());
        },
        child: Text(
          'Forgot Password?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.background),
        ),
      ),
    );
  }

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
