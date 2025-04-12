abstract class HistoryEvent {
  const HistoryEvent(); // Ajout du constructeur constant
}

class LoadHistoryEvent extends HistoryEvent {
  const LoadHistoryEvent(); // Constructeur constant
}

class RecordScanEvent extends HistoryEvent {
  final String productId;

  const RecordScanEvent({required this.productId}); // Constructeur constant
}

class RecordViewEvent extends HistoryEvent {
  final String productId;

  const RecordViewEvent({required this.productId}); // Constructeur constant
}
class DeleteHistoryEvent extends HistoryEvent {
  final String historyId;
  const DeleteHistoryEvent({required this.historyId}); // Constructeur constant
}