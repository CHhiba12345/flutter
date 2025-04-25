class AppUser {
  final String uid;
  final String email;
  final String? jwt;
  final String firstName;
  final String lastName;

  AppUser({
    required this.uid,
    required this.email,
    this.jwt,
    required this.firstName,
    required this.lastName,
  });
}