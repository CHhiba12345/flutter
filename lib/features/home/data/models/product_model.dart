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
    });

    factory ProductModel.fromJson(Map<String, dynamic> json) {
        print("Données JSON reçues dans ProductModel : $json");

        // Gérer les ingrédients
        dynamic ingredients = json['ingredients'];
        List<String> ingredientsList = [];
        if (ingredients is List) {
            ingredientsList = ingredients.map((e) => e.toString()).toList();
        } else if (ingredients is String) {
            ingredientsList = [ingredients];
        }

        // Gérer les catégories
        dynamic categories = json['categories'];
        List<String> categoriesList = [];
        if (categories is List) {
            categoriesList = categories.map((e) => e.toString()).toList();
        } else if (categories is String) {
            categoriesList = [categories];
        }

        // Gérer les allergènes
        dynamic allergens = json['allergens'];
        List<String> allergensList = [];
        if (allergens is List) {
            allergensList = allergens.map((e) => e.toString()).toList();
        } else if (allergens is String) {
            allergensList = [allergens];
        }

        return ProductModel(
            code: json['code'] ?? 'default_code',
            name: json['name']?.toString().trim() ?? 'Unknown Product',
            nutriscore: json['nutriscore']?.toString().trim() ?? 'unknown',
            ingredients: ingredientsList,
            brand: json['brand']?.toString().trim() ?? 'Unknown Brand',
            categories: categoriesList,
            halalStatus: (json['halalStatus'] as bool?) ?? false,
            allergens: allergensList,
            imageUrl: json['imageUrl']?.toString().trim() ?? '',
        );
    }
    Product toEntity() => Product(
    code: code,
    name: name,
    nutriscore: nutriscore,
    ingredients: ingredients,
    brand: brand,
    categories: categories,
    halalStatus: halalStatus,
    allergens: allergens,
    imageUrl: imageUrl,
    );
    }
