class AppUser {
  final String id;
  final String email;
  final String? jwt; // Champ pour stocker le token JWT

  AppUser({
    required this.id,
    required this.email,
    this.jwt,
  });
}