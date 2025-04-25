class AllergenAlert {
  final bool hasAlert;
  final String message;
  final List<String> matchingAllergens;

  AllergenAlert({
    required this.hasAlert,
    required this.message,
    required this.matchingAllergens,
  });
}