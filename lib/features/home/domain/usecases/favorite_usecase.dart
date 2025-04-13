import 'package:eye_volve/core/utils/use_case.dart';
import 'package:eye_volve/features/home/domain/repositories/home_repository.dart';

///
/// usecase is created that contain the injection of Domain Repository
/// so need to injection instance of HomeRepository here and call the execute methode
/// and will handle the result and get it the bloc class
///

class GetFavoriteProduct extends UseCase<List<int>, int> {
  final HomeRepository repository;

  GetFavoriteProduct({required this.repository});

  @override
  List<int> call(int params) {
    return [];
  }
}
