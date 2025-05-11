import 'package:flutter/cupertino.dart';

import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_datasource.dart';
import '../../domain/entities/ticket.dart';
import '../../../auth/data/datasources/auth_service.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketDataSource dataSource;
  final AuthService authService;

  TicketRepositoryImpl({
    required this.dataSource,
    required this.authService,
  });

  @override
  Future<void> sendTicket(Ticket ticket) async {
    final userId = await authService.getCurrentUserId();
    print('👤 [TicketRepository] Sending ticket for user: $userId'); // Ajouté
    debugPrint('📤 Ticket data: ${ticket.storeName}, ${ticket.products.length} products');
    return await dataSource.sendTicketData(ticket);
  }

  @override
  Future<String?> getCurrentUserId() async {
    return await authService.getCurrentUserId();
  }

  @override
  Future<List<Map<String, dynamic>>> getProductPriceComparisons(String productName) async {
    return await dataSource.getProductPriceComparisons(productName);
  }

}