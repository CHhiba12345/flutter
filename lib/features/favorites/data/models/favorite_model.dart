class FavoriteModel {
  final String id;
  final String uid;
  final String productId;
  final String productName;
  final String imageUrl;
  final String timestamp;

  FavoriteModel({
    required this.id,
    required this.uid,
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.timestamp,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['imageUrl'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://via.placeholder.com/150';
    }

    return FavoriteModel(
      id: json['_id'] ?? 'default_id',
      uid: json['uid'] ?? 'default_user_uid',
      productId: json['product_id'] ?? 'default_product_id',
      productName: json['product_name']?.toString().trim() ?? 'Produit inconnu',
      imageUrl: json['image_url']?.toString().trim() ?? 'https://via.placeholder.com/150', // URL par défaut si manquant
      timestamp: json['timestamp']?.toString().trim() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'uid': uid,
      'product_id': productId,
      'product_name': productName,
      'image_url': imageUrl,
      'timestamp': timestamp,
    };
  }
}