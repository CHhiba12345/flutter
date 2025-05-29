import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app_router.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

@RoutePage()
class ResetPasswordPage extends StatelessWidget {
  final String? oobCode;
  final TextEditingController _passwordController = TextEditingController();

  ResetPasswordPage({
    Key? key,
    @QueryParam('oobCode') this.oobCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réinitialisation du mot de passe')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mot de passe réinitialisé avec succès !')),
            );
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) {
                context.router.replace(SignInRoute());
              }
            });
          }

          if (state is ResetPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (oobCode != null &&
                      oobCode!.isNotEmpty &&
                      _passwordController.text.isNotEmpty) {
                    context.read<AuthBloc>().add(
                      PasswordResetRequested(oobCode!, _passwordController.text),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Code ou mot de passe invalide")),
                    );
                  }
                },
                child: const Text('Confirmer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}