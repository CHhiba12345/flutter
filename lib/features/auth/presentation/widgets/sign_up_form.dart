import 'package:flutter/material.dart';

import '../../../../core/constants/app_color_sign_in.dart';


class SignUpForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback togglePasswordVisibility;
  final VoidCallback toggleConfirmPasswordVisibility;
  final GlobalKey<FormState> formKey;

  const SignUpForm({
    Key? key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.togglePasswordVisibility,
    required this.toggleConfirmPasswordVisibility,
    required this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFirstNameField(),
        const SizedBox(height: 15),
        _buildLastNameField(),
        const SizedBox(height: 15),
        _buildEmailField(),
        const SizedBox(height: 15),
        _buildPasswordField(),
        const SizedBox(height: 15),
        _buildConfirmPasswordField(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFirstNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: firstNameController,
        decoration: InputDecoration(
          labelText: 'First Name',
          labelStyle: TextStyle(color: Colors.grey), // Couleur du label en noir
          prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none, // Supprime la bordure
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => _validateName(value, 'First'),
      ),
    );
  }

  Widget _buildLastNameField() {
    return Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
    boxShadow: [
    BoxShadow(
      color: AppColors.shadow.withOpacity(0.3),
    spreadRadius: 5,
    blurRadius: 8,
    offset: Offset(0, 4),
    ),
    ],
    ),
    child: TextFormField(
      controller: lastNameController,
      decoration: InputDecoration(
        labelText: 'Last Name',
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none, // Supprime la bordure
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => _validateName(value, 'Last'),
    ),
    );
  }

  Widget _buildEmailField() {
    return Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
    boxShadow: [
    BoxShadow(
      color: AppColors.shadow.withOpacity(0.3),
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
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none, // Supprime la bordure
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => _validateEmail(value),
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
            color: AppColors.shadow.withOpacity(0.3),
            spreadRadius: 5,
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
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.primary,
          ),
          onPressed: togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none, // Supprime la bordure
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => _validatePassword(value),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
    boxShadow: [
    BoxShadow(
      color: AppColors.shadow.withOpacity(0.3),
    spreadRadius: 5,
    blurRadius: 8,
    offset: Offset(0, 4),
    ),
    ],
    ),
    child: TextFormField(
      controller: confirmPasswordController,
      obscureText: obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.primary,
          ),
          onPressed: toggleConfirmPasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none, // Supprime la bordure
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: _validateConfirmPassword,
    ),
    );
  }

  String? _validateName(String? value, String field) {
    if (value == null || value.isEmpty) return 'Please enter your $field name';
    if (value.length < 2) return '$field name must be at least 2 characters';
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }
}