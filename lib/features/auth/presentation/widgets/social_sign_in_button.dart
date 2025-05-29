import 'package:flutter/material.dart';

/// Bouton générique pour la connexion via un réseau social
///
/// Ce bouton peut être réutilisé pour Google, Facebook, Apple, etc.
class SocialSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SocialSignInButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Sign In with Social Media'),
    );
  }
}