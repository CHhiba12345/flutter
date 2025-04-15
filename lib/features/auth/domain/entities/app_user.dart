class AppUser {
  final String id;
  final String email;
  final String? jwt;
  final String firstName;
  final String lastName;

  AppUser({
    required this.id,
    required this.email,
    this.jwt,
    required this.firstName,
    required this.lastName,
  });
}