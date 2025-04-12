class HistoryModel {
  final String? id;
  final String uid;
  final String productName; // Nouveau
  final String imageUrl;    // Nouveau
  final String productId;
  final String actionType;
  final String timestamp;

  HistoryModel({
    this.id,
    required this.uid,
    required this.productName,
    required this.imageUrl,
    required this.productId,
    required this.actionType,
    required this.timestamp,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['_id'] as String? ?? 'unknown_id', // Gestion de null
      uid: json['uid'] as String? ?? 'unknown_user',
      productName: json['product_name'] ?? 'Produit inconnu', // Nouveau
      imageUrl: json['image_url'] ?? '', // Nouveau
      productId: json['product_id'] as String? ?? '',
      actionType: json['action_type'] as String? ?? 'scan',
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'product_id': productId,
      'productName':productName,
      'imageUrl':imageUrl,

      'actionType': actionType,
      'timestamp': timestamp,
    };
  }
}