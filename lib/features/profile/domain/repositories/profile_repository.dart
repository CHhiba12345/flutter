abstract class ProfileRepository {
  Future<List<String>> setUserAllergens(String uid, List<String> allergens);
  Future<List<String>> getUserAllergens(String uid);
  Future<void> clearUserAllergens(String uid);
}