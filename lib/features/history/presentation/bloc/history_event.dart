abstract class HistoryEvent {
  const HistoryEvent();
}

class LoadHistoryEvent extends HistoryEvent {
  const LoadHistoryEvent();
}

class RecordScanEvent extends HistoryEvent {
  final String productId;

  const RecordScanEvent({required this.productId});
}

class RecordViewEvent extends HistoryEvent {
  final String productId;

  const RecordViewEvent({required this.productId});
}
class DeleteHistoryEvent extends HistoryEvent {
  final String historyId;
  const DeleteHistoryEvent({required this.historyId});
}