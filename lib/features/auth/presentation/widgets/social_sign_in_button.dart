import 'package:flutter/material.dart';

class SocialSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SocialSignInButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Sign In with Social Media'),
    );
  }
}
