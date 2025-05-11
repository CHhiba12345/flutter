// Dans lib/features/ticket/domain/usecases/get_price_comparisons_usecase.dart
import '../repositories/ticket_repository.dart';

class GetPriceComparisonsUseCase {
  final TicketRepository repository;

  GetPriceComparisonsUseCase({required this.repository});

  Future<List<Map<String, dynamic>>> execute(String productName) async {
    try {
      final comparisons = await repository.getProductPriceComparisons(productName);
      return comparisons ?? []; // Garantit de toujours retourner une liste
    } catch (e) {
      return []; // Retourne une liste vide en cas d'erreur
    }
  }
}