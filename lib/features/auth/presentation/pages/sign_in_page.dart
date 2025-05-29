import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app_router.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_form.dart';
import '../widgets/social_login_section.dart';
import '../widgets/sign_in_button.dart';
import '../../../../core/constants/export.dart';

@RoutePage()
class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _showErrors = false;
  String? _emailError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.router.replaceAll([const HomeRoute()]);
          } else if (state is AuthError) {
            // Gestion des erreurs spécifiques
            if (state.message.contains('wrong-password') ||
                state.message.contains('user-not-found')) {
              setState(() {
                _showErrors = true;
                _passwordError = 'Mot de passe incorrect';
              });
            } else {
              String displayMessage = state.message;
              Color backgroundColor = AppColors.error;

              if (state.message == "google_sign_in_failed") {
                displayMessage = "Échec de connexion Google. Réessayez.";
              } else if (state.message == "facebook_sign_in_failed") {
                displayMessage = "Échec de connexion Facebook. Réessayez.";
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    displayMessage,
                    style: AppTextStyles.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  backgroundColor: backgroundColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(20),
                  elevation: 6,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.secondary,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: 20,
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

                        // Formulaire
                        _buildFormContent(state, context),

                        const SizedBox(height: 24),

                        // Connexion sociale
                        SocialLoginSection(
                          onGooglePressed: () =>
                              context.read<AuthBloc>().add(SignInWithGoogleEvent()),
                          onFacebookPressed: () =>
                              context.read<AuthBloc>().add(SignInWithFacebookEvent()),
                        ),

                        const SizedBox(height: 24),

                        // Lien vers inscription
                        _buildSignUpRedirect(context),

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
            'Welcome Back',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 32,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

          const SizedBox(height: 8),

          Text(
            'Sign in to continue',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildFormContent(AuthState state, BuildContext context) {
    return Column(
      children: [
        AuthForm(
          emailController: _emailController,
          passwordController: _passwordController,
          obscurePassword: _obscurePassword,
          togglePasswordVisibility: _togglePasswordVisibility,
          formKey: _formKey,
          showErrors: _showErrors,
          emailError: _emailError,
          passwordError: _passwordError,
        ),
        const SizedBox(height: 24),
        SignInButton(
          state: state,
          onPressed: _submitForm,
        ).animate().fadeIn(delay: 300.ms),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2);
  }

  Widget _buildSignUpRedirect(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: "Don't have an account? ",
          style: AppTextStyles.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
          children: [
            WidgetSpan(
              child: InkWell(
                onTap: () => context.router.push(const SignUpRoute()),
                splashColor: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Sign Up',
                    style: AppTextStyles.button?.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
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

  void _submitForm() {
    setState(() {
      _showErrors = true;
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    if (_emailError == null && _passwordError == null) {
      context.read<AuthBloc>().add(
        SignInWithEmailAndPasswordEvent(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ),
      );
    }
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