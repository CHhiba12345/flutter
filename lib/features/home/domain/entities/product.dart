class Product {
  final String code;
  final String name;
  final String nutriscore;
  final List<String> ingredients; // Doit être List<String>
  final String brand;
  final List<String> categories; // Doit être List<String>
  final bool halalStatus;
  final List<String> allergens; // Doit être List<String>
  final String imageUrl;
  final bool isFavorite;
  Product({
    required this.code,
    required this.name,
    required this.nutriscore,
    required this.ingredients, // Type corrigé
    required this.brand,
    required this.categories, // Type corrigé
    required this.halalStatus,
    required this.allergens, // Type corrigé
    required this.imageUrl,
    required this.isFavorite,
  });



}