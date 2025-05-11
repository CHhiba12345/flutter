abstract class TicketState {}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketScanSuccess extends TicketState {}

class TicketSentSuccess extends TicketState {}


class TicketAnalysisSuccess extends TicketState {
  final Map<String, dynamic> analysis;
  final Map<String, dynamic> receiptData; // Ajout des données brutes
  final List<Map<String, dynamic>>? comparisons;

  TicketAnalysisSuccess({
    required this.analysis,
    required this.receiptData,
    this.comparisons,
  });
  TicketAnalysisSuccess copyWith({
    Map<String, dynamic>? analysis,
    Map<String, dynamic>? receiptData,
    List<Map<String, dynamic>>? comparisons,
  }) {
    return TicketAnalysisSuccess(
      analysis: analysis ?? this.analysis,
      receiptData: receiptData ?? this.receiptData,
      comparisons: comparisons ?? this.comparisons,
    );
  }
}

class TicketError extends TicketState {
  final String message;

  TicketError(this.message);
}
class PriceComparisonsLoaded extends TicketState {
  final List<Map<String, dynamic>> comparisons;

  PriceComparisonsLoaded({required this.comparisons});
}