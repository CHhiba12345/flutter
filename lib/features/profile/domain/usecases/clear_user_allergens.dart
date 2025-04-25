import '../repositories/profile_repository.dart';

class ClearUserAllergens {
  final ProfileRepository repository;

  ClearUserAllergens(this.repository);

  Future<void> call(String uid) async {
    return repository.clearUserAllergens(uid);
  }
}