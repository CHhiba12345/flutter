import 'package:auto_route/annotations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
@RoutePage()
class ForgotPasswordPage extends StatelessWidget {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mot de passe oublié')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is ForgotPasswordSuccess) {
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    ForgotPasswordRequested(_emailController.text),
                  );
                },
                child: Text('Envoyer le lien'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}