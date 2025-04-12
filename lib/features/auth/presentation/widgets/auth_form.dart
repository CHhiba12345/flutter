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

  const AuthForm({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.togglePasswordVisibility,
    required this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {  // Le context est passé ici
    return Column(
      children: [
        _buildEmailField(),
        const SizedBox(height: 20),
        _buildPasswordField(),
        const SizedBox(height: 2),
        _buildForgotPassword(context),  // Passer le context ici
      ],
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: false,
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: passwordController,
        obscureText: obscurePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
            ),
            onPressed: togglePasswordVisibility,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: false,
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
          context.router.push(const ForgotPasswordRoute());
        },
        child: Text(
          'Forgot Password?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
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
