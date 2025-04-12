class History {
  final String? id;
  final String uid;
  final String productName;
  final String imageUrl;
  final String productId;
  final String actionType;
  final String timestamp;
  History({
    this.id,
    required this.uid,
    required this.productName,
    required this.imageUrl,
    required this.productId,
    required this.actionType,
    required this.timestamp,
  });
}