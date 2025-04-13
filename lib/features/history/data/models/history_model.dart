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
    print('[HistoryModel] Raw JSON: $json'); // Log du JSON reçu

    final id = json['_id']?.toString() ?? 'unknown_id'; // Conversion forcée en String
    print('[HistoryModel] Parsed ID: $id');

    return HistoryModel(
      id: id,
      uid: json['uid']?.toString() ?? 'unknown_user',
      productName: json['product_name'] ?? json['productName'] ?? 'Produit inconnu',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      productId: json['product_id']?.toString() ?? json['productId']?.toString() ?? '',
      actionType: json['action_type']?.toString() ?? json['actionType']?.toString() ?? 'scan',
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
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