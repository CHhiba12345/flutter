
import '../../domain/entities/product.dart';

class ProductModel {
    final String code;
    final String name;
    final String? nutriscore;
    final NutritionModel? nutrition;
    final IngredientsModel? ingredients;
    final ProcessingModel? processing;
    final EnvironmentModel? environment;
    final String? categories;
    final String? brand;
    final bool? halalStatus;
    final String? imageUrl;
    final bool? isFavorite;
    final bool? hasAllergenAlert;
    final String? alertMessage;

    ProductModel({
        required this.code,
        required this.name,
        this.nutriscore,
        this.nutrition,
        this.ingredients,
        this.processing,
        this.environment,
        this.categories,
        this.brand,
        this.halalStatus,
        this.imageUrl,
        this.isFavorite,
        this.hasAllergenAlert,
        this.alertMessage,
    });

    factory ProductModel.fromJson(Map<String, dynamic> json) {
        // Gestion spéciale pour le champ 'categories' qui peut être une String ou une List
        dynamic categories = json['categories'];
        String? categoriesString;

        if (categories is List) {
            categoriesString = categories.join(', ');
        } else if (categories is String) {
            categoriesString = categories;
        }

        return ProductModel(
            code: json['code']?.toString() ?? 'default_code',
            name: (json['name']?.toString() ?? 'Unknown Product').trim(),
            nutriscore: json['nutriscore']?.toString().trim(),
            nutrition: json['nutrition'] != null && json['nutrition'] is Map
                ? NutritionModel.fromJson(json['nutrition'])
                : null,
            ingredients: json['ingredients'] != null && json['ingredients'] is Map
                ? IngredientsModel.fromJson(json['ingredients'])
                : null,
            processing: json['processing'] != null && json['processing'] is Map
                ? ProcessingModel.fromJson(json['processing'])
                : null,
            environment: json['environment'] != null && json['environment'] is Map
                ? EnvironmentModel.fromJson(json['environment'])
                : null,
            categories: categoriesString,
            brand: json['brand']?.toString().trim(),
            halalStatus: json['halalStatus'] is bool
                ? json['halalStatus']
                : json['halalStatus']?.toString().toLowerCase() == 'true',
            imageUrl: json['imageUrl']?.toString().trim(),
            isFavorite: json['isFavorite'] is bool
                ? json['isFavorite']
                : json['isFavorite']?.toString().toLowerCase() == 'true',
            hasAllergenAlert: json['hasAllergenAlert'] is bool
                ? json['hasAllergenAlert']
                : json['hasAllergenAlert']?.toString().toLowerCase() == 'true',
            alertMessage: json['alertMessage']?.toString().trim(),
        );
    }

    Product toEntity() => Product(
        code: code,
        name: name,
        nutriscore: nutriscore,
        nutrition: nutrition?.toEntity(),
        ingredients: ingredients?.toEntity(),
        processing: processing?.toEntity(),
        environment: environment?.toEntity(),
        categories: categories,
        brand: brand,
        halalStatus: halalStatus,
        imageUrl: imageUrl,
        isFavorite: isFavorite,
        hasAllergenAlert: hasAllergenAlert,
        alertMessage: alertMessage,
    );
}

class NutritionModel {
    final NutrientLevelsModel? nutrientLevels;
    final NutritionFactsModel? facts;

    NutritionModel({
        this.nutrientLevels,
        this.facts,
    });

    factory NutritionModel.fromJson(Map<String, dynamic> json) {
        return NutritionModel(
            nutrientLevels: json['nutrientLevels'] != null
                ? NutrientLevelsModel.fromJson(json['nutrientLevels'])
                : null,
            facts: json['facts'] != null
                ? NutritionFactsModel.fromJson(json['facts'])
                : null,
        );
    }

    Nutrition toEntity() => Nutrition(
        nutrientLevels: nutrientLevels?.toEntity(),
        facts: facts?.toEntity(),
    );
}

class NutrientLevelsModel {
    final String? fat;
    final String? salt;
    final String? saturatedFat;
    final String? sugars;

    NutrientLevelsModel({
        this.fat,
        this.salt,
        this.saturatedFat,
        this.sugars,
    });

    factory NutrientLevelsModel.fromJson(Map<String, dynamic> json) {
        return NutrientLevelsModel(
            fat: json['fat'] as String?,
            salt: json['salt'] as String?,
            saturatedFat: json['saturatedFat'] as String?,
            sugars: json['sugars'] as String?,
        );
    }

    NutrientLevels toEntity() => NutrientLevels(
        fat: fat,
        salt: salt,
        saturatedFat: saturatedFat,
        sugars: sugars,
    );
}

class NutritionFactsModel {
    final double? energyKcal;
    final double? fat;
    final double? carbohydrates;
    final double? proteins;
    final double? salt;

    NutritionFactsModel({
        this.energyKcal,
        this.fat,
        this.carbohydrates,
        this.proteins,
        this.salt,
    });

    factory NutritionFactsModel.fromJson(Map<String, dynamic> json) {
        return NutritionFactsModel(
            energyKcal: (json['energyKcal'] as num?)?.toDouble(),
            fat: (json['fat'] as num?)?.toDouble(),
            carbohydrates: (json['carbohydrates'] as num?)?.toDouble(),
            proteins: (json['proteins'] as num?)?.toDouble(),
            salt: (json['salt'] as num?)?.toDouble(),
        );
    }

    NutritionFacts toEntity() => NutritionFacts(
        energyKcal: energyKcal,
        fat: fat,
        carbohydrates: carbohydrates,
        proteins: proteins,
        salt: salt,
    );
}

class IngredientsModel {
    final String? text;
    final IngredientsAnalysisModel? analysis;
    final List<String>? allergens;

    IngredientsModel({
        this.text,
        this.analysis,
        this.allergens,
    });

    factory IngredientsModel.fromJson(Map<String, dynamic> json) {
        return IngredientsModel(
            text: (json['text'] as String?)?.trim(),
            analysis: json['analysis'] != null
                ? IngredientsAnalysisModel.fromJson(json['analysis'])
                : null,
            allergens: json['allergens'] is List
                ? List<String>.from(json['allergens'].map((x) => x.toString()))
                : null,
        );
    }

    Ingredients toEntity() => Ingredients(
        text: text,
        analysis: analysis?.toEntity(),
        allergens: allergens,
    );
}

class IngredientsAnalysisModel {
    final bool? vegan;
    final bool? vegetarian;
    final bool? palmOil;

    IngredientsAnalysisModel({
        this.vegan,
        this.vegetarian,
        this.palmOil,
    });

    factory IngredientsAnalysisModel.fromJson(Map<String, dynamic> json) {
        return IngredientsAnalysisModel(
            vegan: json['vegan'] as bool?,
            vegetarian: json['vegetarian'] as bool?,
            palmOil: json['palmOil'] as bool?,
        );
    }

    IngredientsAnalysis toEntity() => IngredientsAnalysis(
        vegan: vegan,
        vegetarian: vegetarian,
        palmOil: palmOil,
    );
}

class ProcessingModel {
    final int? novaGroup;
    final List<String>? additives;

    ProcessingModel({
        this.novaGroup,
        this.additives,
    });

    factory ProcessingModel.fromJson(Map<String, dynamic> json) {
        return ProcessingModel(
            novaGroup: json['novaGroup'] as int?,
            additives: json['additives'] is List
                ? List<String>.from(json['additives'].map((x) => x.toString()))
                : null,
        );
    }

    Processing toEntity() => Processing(
        novaGroup: novaGroup,
        additives: additives,
    );
}

class EnvironmentModel {
    final String? ecoscore;
    final double? carbonFootprint;
    final List<String>? packaging;

    EnvironmentModel({
        this.ecoscore,
        this.carbonFootprint,
        this.packaging,
    });

    factory EnvironmentModel.fromJson(Map<String, dynamic> json) {
        return EnvironmentModel(
            ecoscore: (json['ecoscore'] as String?)?.trim(),
            carbonFootprint: (json['carbonFootprint'] as num?)?.toDouble(),
            packaging: json['packaging'] is List
                ? List<String>.from(json['packaging'].map((x) => x.toString()))
                : null,
        );
    }

    Environment toEntity() => Environment(
        ecoscore: ecoscore,
        carbonFootprint: carbonFootprint,
        packaging: packaging,
    );
}