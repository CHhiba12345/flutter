import '../../domain/entities/ticket.dart';

abstract class TicketEvent {}

class ScanTicketEvent extends TicketEvent {}

class SendTicketEvent extends TicketEvent {
  final Ticket ticket;

  SendTicketEvent({required this.ticket});
}
class GetPriceComparisonsEvent extends TicketEvent {
  final String productName;

  GetPriceComparisonsEvent({required this.productName});
}