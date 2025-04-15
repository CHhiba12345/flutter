class UserModel {
  final String uid;
  final String email;
  final String? jwt;
  final String firstName;
  final String lastName;

  UserModel({
    required this.uid,
    required this.email,
    required this.jwt,
    required this.firstName,
    required this.lastName,
  });
}