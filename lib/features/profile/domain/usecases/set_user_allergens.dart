
import '../repositories/profile_repository.dart';

class SetUserAllergens {
  final ProfileRepository repository;

  SetUserAllergens(this.repository);

  Future<List<String>> call(String uid, List<String> allergens) async {
    return repository.setUserAllergens(uid, allergens);
  }
}

