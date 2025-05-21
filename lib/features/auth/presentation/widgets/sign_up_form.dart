import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SignUpForm extends StatefulWidget {
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
  final String? externalError; // Ajoutez ce paramètre

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
    this.externalError, // Ajoutez ce paramètre
  }) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  String? _emailError;

  @override
  void didUpdateWidget(covariant SignUpForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalError != oldWidget.externalError) {
      // Si l'erreur externe concerne l'email, on l'affiche
      if (widget.externalError?.contains('email') ?? false) {
        setState(() {
          _emailError = widget.externalError;
        });
      }
    }
  }
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _firstNameFocus.addListener(() => setState(() {}));
    _lastNameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmPasswordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

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
    return TextFormField(
      controller: widget.firstNameController,
      focusNode: _firstNameFocus,
      decoration: InputDecoration(
        hintText: _firstNameFocus.hasFocus ? null : 'First Name',
        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: Colors.red), // Add this line
        errorBorder: OutlineInputBorder( // Optional: customize error border
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: (value) => _validateName(value, 'First'),
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: widget.lastNameController,
      focusNode: _lastNameFocus,
      decoration: InputDecoration(
        hintText: _lastNameFocus.hasFocus ? null : 'Last Name',
        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: Colors.red), // Add this line
        errorBorder: OutlineInputBorder( // Optional: customize error border
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: (value) => _validateName(value, 'Last'),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: widget.emailController,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: _emailFocus.hasFocus ? null : 'Email',
        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        errorText: _emailError, // Utilisez l'erreur locale ou externe
        errorStyle: const TextStyle(color: Colors.red),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: (value) {
        // Réinitialise l'erreur quand l'utilisateur modifie le texte
        if (_emailError != null && value != widget.emailController.text) {
          setState(() {
            _emailError = null;
          });
        }
        return _validateEmail(value);
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: widget.passwordController,
      focusNode: _passwordFocus,
      obscureText: widget.obscurePassword,
      decoration: InputDecoration(
        hintText: _passwordFocus.hasFocus ? null : 'Password',
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            widget.obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.primary,
          ),
          onPressed: widget.togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: Colors.red), // Add this line
        errorBorder: OutlineInputBorder( // Optional: customize error border
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: _validatePassword,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: widget.confirmPasswordController,
      focusNode: _confirmPasswordFocus,
      obscureText: widget.obscureConfirmPassword,
      decoration: InputDecoration(
        hintText: _confirmPasswordFocus.hasFocus ? null : 'Confirm Password',
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            widget.obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.primary,
          ),
          onPressed: widget.toggleConfirmPasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        // Error styling
        errorStyle: const TextStyle(color: Colors.red), // Add this line
        errorBorder: OutlineInputBorder( // Optional: customize error border
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: _validateConfirmPassword,
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
    if (value != widget.passwordController.text) return 'Passwords do not match';
    return null;
  }
}