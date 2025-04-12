import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class GetFirebaseToken {
  final AuthRepository authRepository;

  GetFirebaseToken(this.authRepository);

  Future<String?> call() async {
    // Utiliser éventuellement authRepository pour récupérer le token,
    // ou laisser FirebaseAuth.instance.currentUser.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }
}
