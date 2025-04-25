import 'package:eye_volve/features/profile/data/datasources/profile_datasource.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSourceImpl dataSource;

  ProfileRepositoryImpl({required this.dataSource});

  @override
  Future<List<String>> setUserAllergens(String uid, List<String> allergens) async {
    try {
      return await dataSource.setUserAllergens(uid, allergens);
    } catch (e) {
      throw Exception('Failed to set user allergens');
    }
  }

  @override
  Future<List<String>> getUserAllergens(String uid) async {
    try {
      return await dataSource.getUserAllergens(uid);
    } catch (e) {
      throw Exception('Failed to load user allergens');
    }
  }

  @override
  Future<void> clearUserAllergens(String uid) async {
    try {
      await dataSource.clearUserAllergens(uid);
    } catch (e) {
      throw Exception('Failed to clear user allergens');
    }
  }
}