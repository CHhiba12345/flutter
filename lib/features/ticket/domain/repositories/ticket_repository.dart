import '../entities/ticket.dart';

abstract class TicketRepository {
  Future<void> sendTicket(Ticket ticket);
  Future<String?> getCurrentUserId();
  Future<List<Map<String, dynamic>>> getProductPriceComparisons(String productName);
}