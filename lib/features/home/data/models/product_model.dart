import '../../domain/entities/product.dart';

class ProductModel {
  final String code;
  final String name;
  final String nutriscore;
  final List<String> ingredients;
  final String brand;
  final List<String> categories;
  final bool halalStatus;
  final List<String> allergens;
  final String imageUrl;
  final bool isFavorite; // 👈 Ajouté

  ProductModel({
    required this.code,
    required this.name,
    required this.nutriscore,
    required this.ingredients,
    required this.brand,
    required this.categories,
    required this.halalStatus,
    required this.allergens,
    required this.imageUrl,
    this.isFavorite = false, // 👈 Par défaut false
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    dynamic ingredients = json['ingredients'];
    List<String> ingredientsList = [];
    if (ingredients is List) {
      ingredientsList = ingredients.map((e) => e.toString()).toList();
    } else if (ingredients is String) {
      ingredientsList = [ingredients];
    }

    dynamic categories = json['categories'];
    List<String> categoriesList = [];
    if (categories is List) {
      categoriesList = categories.map((e) => e.toString()).toList();
    } else if (categories is String) {
      categoriesList = [categories];
    }

    dynamic allergens = json['allergens'];
    List<String> allergensList = [];
    if (allergens is List) {
      allergensList = allergens.map((e) => e.toString()).toList();
    } else if (allergens is String) {
      allergensList = [allergens];
    }

    return ProductModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      nutriscore: json['nutriscore'] ?? '',
      ingredients: ingredientsList,
      brand: json['brand'] ?? '',
      categories: categoriesList,
      halalStatus: json['halal_status'] ?? false,
      allergens: allergensList,
      imageUrl: json['image_url'] ?? '',
    );
  }

  // 🔥 Ajout d'un copyWith pour pouvoir modifier isFavorite
  ProductModel copyWith({bool? isFavorite}) {
    return ProductModel(
      code: code,
      name: name,
      nutriscore: nutriscore,
      ingredients: ingredients,
      brand: brand,
      categories: categories,
      halalStatus: halalStatus,
      allergens: allergens,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // 🔥 Méthode pour convertir en entité (domain layer)
  Product toEntity() {
    return Product(
      code: code,
      name: name,
      nutriscore: nutriscore,
      ingredients: ingredients,
      brand: brand,
      categories: categories,
      halalStatus: halalStatus,
      allergens: allergens,
      imageUrl: imageUrl,
      isFavorite: isFavorite, // 👈 bien propager dans l'entité
    );
  }
}
