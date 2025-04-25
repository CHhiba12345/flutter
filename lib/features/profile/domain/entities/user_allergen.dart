class UserAllergen {
  final String? id;
  final String uid;
  final List<String> allergens;

  UserAllergen({
    this.id,
    required this.uid,
    required this.allergens,
  });
}