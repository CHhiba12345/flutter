class UserAllergenModel {
  final String? id;
  final String uid;
  final List<String> allergens;

  UserAllergenModel({
    this.id,
    required this.uid,
    required this.allergens,
  });

  factory UserAllergenModel.fromJson(Map<String, dynamic> json) {
    return UserAllergenModel(
      id: json['id'],
      uid: json['uid'],
      allergens: List<String>.from(json['allergens']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'allergens': allergens,
    };
  }
}