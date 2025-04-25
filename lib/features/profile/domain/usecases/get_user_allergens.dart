

import '../repositories/profile_repository.dart';

class GetUserAllergens {
  final ProfileRepository repository;

  GetUserAllergens(this.repository);

  Future<List<String>> call(String uid) async {
    return repository.getUserAllergens(uid);
  }
}
