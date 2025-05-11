// Dans lib/features/ticket/domain/usecases/get_price_comparisons_usecase.dart
import '../repositories/ticket_repository.dart';

class GetPriceComparisonsUseCase {
  final TicketRepository repository;

  GetPriceComparisonsUseCase({required this.repository});

  Future<List<Map<String, dynamic>>> execute(String productName) async {
    return await repository.getProductPriceComparisons(productName);
  }
}