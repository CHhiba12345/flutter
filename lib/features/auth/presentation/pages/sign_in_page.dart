import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lottie/lottie.dart';
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Connexion réussie !')),
            );
            context.router.replaceAll([const HomeRoute()]);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Container(
            height: size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.background, AppColors.secondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.1,
                vertical: 50,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Card(
                        elevation: 9,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Lottie.asset(
                              AppAssets.lottieAnimation,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Sign in to continue',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    AuthForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      togglePasswordVisibility: _togglePasswordVisibility,
                      formKey: _formKey,
                    ),
                    const SizedBox(height: 10),
                    SignInButton(
                      state: state,
                      onPressed: _submitForm,
                    ),
                    const SizedBox(height: 20),
                    SocialLoginSection(
                      onGooglePressed: () => context.read<AuthBloc>().add(SignInWithGoogleEvent()),
                      onFacebookPressed: () => context.read<AuthBloc>().add(SignInWithFacebookEvent()),
                    ),
                    const SizedBox(height: 20),
                    _buildSignUpRedirect(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _togglePasswordVisibility() => setState(() => _obscurePassword = !_obscurePassword);

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        SignInWithEmailAndPasswordEvent(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ),
      );
    }
  }

  Widget _buildSignUpRedirect(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTextStyles.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.router.push(SignUpRoute()),
          child: Text(
            'Sign Up',
            style: AppTextStyles.button,
          ),
        ),
      ],
    );
  }
}