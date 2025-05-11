import 'package:flutter/cupertino.dart';

import '../repositories/ticket_repository.dart';
import '../entities/ticket.dart';

class SendTicketUseCase {
  final TicketRepository repository;

  SendTicketUseCase({required this.repository});

  Future<void> execute(Ticket ticket) async {
    final userId = await repository.getCurrentUserId();
    print('🚀 [SendTicketUseCase] Current user ID: $userId'); // Ajouté

    if (userId == null) {
      print('⚠️ No authenticated user found'); // Ajouté
      throw Exception('User not authenticated');
    }

    debugPrint('🛫 Sending ticket with user ID: $userId');
    await repository.sendTicket(ticket);
    print('🎉 Ticket successfully sent for user: $userId'); // Ajouté
  }
}