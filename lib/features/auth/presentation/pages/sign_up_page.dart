import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/sign_up_form.dart';
import '../widgets/sign_up_button.dart';

@RoutePage()
class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _emailError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.router.replaceAll([const AllergensRoute()]);
          } else if (state is AuthError) {
            // On gère uniquement les erreurs liées à l'email
            if (state.message.toLowerCase().contains('email')) {
              setState(() {
                _emailError = state.message;
              });
            }
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.secondary,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - MediaQuery.of(context).padding.vertical,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),

                        // En-tête
                        _buildHeader(),

                        const SizedBox(height: 32),

                        // Formulaire d'inscription
                        SignUpForm(
                          firstNameController: _firstNameController,
                          lastNameController: _lastNameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          obscurePassword: _obscurePassword,
                          obscureConfirmPassword: _obscureConfirmPassword,
                          togglePasswordVisibility: _togglePasswordVisibility,
                          toggleConfirmPasswordVisibility: _toggleConfirmPasswordVisibility,
                          formKey: _formKey,
                          externalError: _emailError,
                        ),

                        const SizedBox(height: 24),

                        // Bouton d'inscription
                        SignUpButton(
                          state: state,
                          onPressed: _submitForm,
                        ).animate().fadeIn(delay: 300.ms),

                        const SizedBox(height: 24),

                        // Redirection vers connexion
                        _buildSignInRedirect(context),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // === UI Builders ===

  Widget _buildHeader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge?.copyWith(
              color: Color(0xFFD5D5D5),
              fontWeight: FontWeight.bold,
              fontSize: 32,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

          const SizedBox(height: 8),

          Text(
            'Join our community today',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildSignInRedirect(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'Already have an account? ',
          style: AppTextStyles.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
          children: [
            WidgetSpan(
              child: InkWell(
                onTap: () => context.router.push(const SignInRoute()),
                child: Text(
                  'Sign In',
                  style: AppTextStyles.button?.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms),
    );
  }

  // === Actions ===

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        SignUpWithEmailAndPasswordEvent(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
        ),
      );
    }
  }
}