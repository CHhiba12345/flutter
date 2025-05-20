abstract class TicketState {}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketScanSuccess extends TicketState {}

class TicketSentSuccess extends TicketState {}


class TicketAnalysisSuccess extends TicketState {
  final Map<String, dynamic> analysis;
  final Map<String, dynamic> receiptData;
  final List<dynamic> priceComparisons; // Nouveau champ

  TicketAnalysisSuccess({
    required this.analysis,
    required this.receiptData,
    this.priceComparisons = const [],
  });
}

class TicketError extends TicketState {
  final String message;

  TicketError(this.message);
}
class PriceComparisonsLoaded extends TicketState {
  final List<Map<String, dynamic>> comparisons;
  final Map<String, dynamic> currentAnalysis;
  final Map<String, dynamic> currentReceiptData;

  PriceComparisonsLoaded({
    required this.comparisons,
    required this.currentAnalysis,
    required this.currentReceiptData, required String productName,
  });
}
