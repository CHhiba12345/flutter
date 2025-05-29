import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

// Use case pour récupérer le token Firebase de l'utilisateur connecté
class GetFirebaseToken {
  final AuthRepository authRepository;

  GetFirebaseToken(this.authRepository);

  // Récupère le token JWT actuel de l'utilisateur
  Future<String?> call() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken(); // Génère un nouveau token si nécessaire
    }
    return null; // Aucun utilisateur connecté
  }
}