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
    return FavoriteModel(
      id: json['_id'],
      uid: json['uid'],
      productId: json['product_id'],
      productName: json['product_name'] ?? 'Unknown Product',
      imageUrl: json['image_url'] ?? '',
      timestamp: json['timestamp'],
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