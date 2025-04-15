class HistoryModel {
  final String id;
  final String uid;
  final String productName; // Nouveau
  final String imageUrl;    // Nouveau
  final String productId;
  final String actionType;
  final String timestamp;

  HistoryModel({
    required this.id,
    required this.uid,
    required this.productName,
    required this.imageUrl,
    required this.productId,
    required this.actionType,
    required this.timestamp,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    // Récupérer _id du JSON (maintenant présent)
    final id = json['_id']?.toString();
    if (id == null) {
      throw FormatException('_id manquant dans : $json');
    }

    return HistoryModel(
      id: id, // Maintenant obligatoire
      uid: json['uid'] as String,
      productName: (json['productName'] ?? json['product_name'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '') as String,
      productId: (json['productId'] ?? json['product_id']) as String,
      actionType: (json['actionType'] ?? json['action_type']) as String,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'uid': uid,
      'product_id': productId,
      'productName':productName,
      'imageUrl':imageUrl,

      'actionType': actionType,
      'timestamp': timestamp,
    };
  }
}