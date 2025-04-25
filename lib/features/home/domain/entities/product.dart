class Product {
  final String code;
  final String name;
  final String? nutriscore;
  final Nutrition? nutrition;
  final Ingredients? ingredients;
  final Processing? processing;
  final Environment? environment;
  final String? categories;
  final String? brand;
  final bool? halalStatus;
  final String? imageUrl;
  final bool? isFavorite;
  final bool? hasAllergenAlert;
  final String? alertMessage;

  Product({
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
}

class Nutrition {
  final NutrientLevels? nutrientLevels;
  final NutritionFacts? facts;

  Nutrition({
    this.nutrientLevels,
    this.facts,
  });
}

class NutrientLevels {
  final String? fat;
  final String? salt;
  final String? saturatedFat;
  final String? sugars;

  NutrientLevels({
    this.fat,
    this.salt,
    this.saturatedFat,
    this.sugars,
  });
}

class NutritionFacts {
  final double? energyKcal;
  final double? fat;
  final double? carbohydrates;
  final double? proteins;
  final double? salt;

  NutritionFacts({
    this.energyKcal,
    this.fat,
    this.carbohydrates,
    this.proteins,
    this.salt,
  });
}

class Ingredients {
  final String? text;
  final IngredientsAnalysis? analysis;
  final List<String>? allergens;

  Ingredients({
    this.text,
    this.analysis,
    this.allergens,
  });
}

class IngredientsAnalysis {
  final bool? vegan;
  final bool? vegetarian;
  final bool? palmOil;

  IngredientsAnalysis({
    this.vegan,
    this.vegetarian,
    this.palmOil,
  });
}

class Processing {
  final int? novaGroup;
  final List<String>? additives;

  Processing({
    this.novaGroup,
    this.additives,
  });
}

class Environment {
  final String? ecoscore;
  final double? carbonFootprint;
  final List<String>? packaging;

  Environment({
    this.ecoscore,
    this.carbonFootprint,
    this.packaging,
  });
}