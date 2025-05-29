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
  final String? externalError; // Erreur venant de l'extérieur (ex: AuthError)

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
    this.externalError,
  }) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  String? _emailError;

  @override
  void didUpdateWidget(covariant SignUpForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Met à jour l'erreur si elle vient de l'extérieur (ex: email déjà utilisé)
    if (widget.externalError != oldWidget.externalError &&
        widget.externalError?.contains('email') == true) {
      setState(() {
        _emailError = widget.externalError;
      });
    }
  }

  // FocusNodes pour gérer les états visuels des champs
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Écoute les changements de focus pour rafraîchir l'UI
    _firstNameFocus.addListener(() => setState(() {}));
    _lastNameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _confirmPasswordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // Nettoyage des listeners
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

  // === Champs du formulaire ===

  /// Champ : Prénom
  Widget _buildFirstNameField() {
    return TextFormField(
      controller: widget.firstNameController,
      focusNode: _firstNameFocus,
      decoration: InputDecoration(
        hintText: _firstNameFocus.hasFocus ? null : 'First Name',
        prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: AppColors.error),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      validator: (value) => _validateName(value, 'First'),
    );
  }

  /// Champ : Nom
  Widget _buildLastNameField() {
    return TextFormField(
      controller: widget.lastNameController,
      focusNode: _lastNameFocus,
      decoration: InputDecoration(
        hintText: _lastNameFocus.hasFocus ? null : 'Last Name',
        prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: AppColors.error),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      validator: (value) => _validateName(value, 'Last'),
    );
  }

  /// Champ : Email
  Widget _buildEmailField() {
    return TextFormField(
      controller: widget.emailController,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: _emailFocus.hasFocus ? null : 'Email',
        prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        errorText: _emailError,
        errorStyle: const TextStyle(color: AppColors.error),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      validator: (value) {
        // Réinitialise l'erreur personnalisée quand l'utilisateur modifie le champ
        if (_emailError != null && value != widget.emailController.text) {
          setState(() {
            _emailError = null;
          });
        }
        return _validateEmail(value);
      },
    );
  }

  /// Champ : Mot de passe
  Widget _buildPasswordField() {
    return TextFormField(
      controller: widget.passwordController,
      focusNode: _passwordFocus,
      obscureText: widget.obscurePassword,
      decoration: InputDecoration(
        hintText: _passwordFocus.hasFocus ? null : 'Password',
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(widget.obscurePassword ? Icons.visibility_off : Icons.visibility),
          color: AppColors.primary,
          onPressed: widget.togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: AppColors.error),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      validator: _validatePassword,
    );
  }

  /// Champ : Confirmer mot de passe
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: widget.confirmPasswordController,
      focusNode: _confirmPasswordFocus,
      obscureText: widget.obscureConfirmPassword,
      decoration: InputDecoration(
        hintText: _confirmPasswordFocus.hasFocus ? null : 'Confirm Password',
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(widget.obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
          color: AppColors.primary,
          onPressed: widget.toggleConfirmPasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: AppColors.error),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      validator: _validateConfirmPassword,
    );
  }

  // === Validations ===

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