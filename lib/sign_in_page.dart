import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'home_page.dart';
import 'sign_up_page.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Fonction de connexion avec email et mot de passe
    Future<void> signIn(String email, String password) async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion : $e')),
        );
      }
    }

    // Fonction de connexion avec Google
    Future<User?> signInWithGoogle() async {
      try {
        // Déconnecter tout compte Google actuel avant de forcer la sélection de compte
        await GoogleSignIn().signOut();

        // Déclencher le flux d'authentification Google avec la sélection de compte forcée
        final GoogleSignInAccount? googleUser = await GoogleSignIn(
          forceCodeForRefreshToken: true, // Force la sélection du compte
        ).signIn();

        if (googleUser == null) {
          // L'utilisateur a annulé l'authentification
          return null;
        }

        // Obtenir l'authentification de Google
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Créer un nouvel identifiant d'authentification Firebase avec les informations d'authentification Google
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Authentifier l'utilisateur avec Firebase
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        // Vérifier si l'utilisateur est connecté
        if (userCredential.user != null) {
          // Rediriger vers la page d'accueil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion Google : $e')),
        );
      }
    }

    // Fonction de connexion avec Facebook
    Future<User?> signInWithFacebook() async {
      // Déclencher le flux d'authentification Facebook
      final LoginResult loginResult = await FacebookAuth.instance.login(permissions: ['public_profile', 'email'],);

      if (loginResult.status == LoginStatus.success) {
        // Créer un credential avec le token d'accès
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

        // Connecter l'utilisateur avec Firebase
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

        // Retourner l'utilisateur
        return userCredential.user;
      } else {
        // Gérer l'erreur
        print("Erreur de connexion Facebook : ${loginResult.status}");
        return null;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => signIn(emailController.text, passwordController.text),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Or sign in with',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            SignInButton(
              Buttons.Google,
              onPressed: signInWithGoogle,
            ),
            SignInButton(
              Buttons.Facebook,
              onPressed: signInWithFacebook,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
