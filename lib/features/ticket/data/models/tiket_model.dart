import '../../domain/entities/ticket.dart';

class TicketModel extends Ticket {
  TicketModel({
    required String storeName,
    required DateTime receiptDate, // Changé de String à DateTime
    required List<Product> products,
    required double totalAmount,
    String? userId,
  }) : super(
    storeName: storeName,
    receiptDate: receiptDate, // Maintenant DateTime
    products: products,
    totalAmount: totalAmount,
    userId: userId,
  );

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final productsList = (json['products'] as List)
        .map((productJson) => Product.fromJson(productJson))
        .toList();

    return TicketModel(
      storeName: json['storeName'] ?? 'Inconnu',
      receiptDate: _parseDate(json['receiptDate']), // Parse en DateTime
      products: productsList,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ??
          _calculateTotalFromProducts(productsList),
      userId: json['userId'],
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null || value.toString().toLowerCase() == 'unknown date') {
      return DateTime.now().toUtc(); // Retourne DateTime directement
    }

    if (value is DateTime) {
      return value.toUtc();
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed.toUtc();

      final parts = value.split('/');
      if (parts.length == 3) {
        final day = parts[0];
        final month = parts[1];
        final year = parts[2];
        final correctedFormat = '$year-$month-$day';
        final date = DateTime.tryParse(correctedFormat);
        if (date != null) return date.toUtc();
      }
    }

    return DateTime.now().toUtc(); // Fallback DateTime
  }

  static double _calculateTotalFromProducts(List<Product> products) {
    return products.fold(0.0, (sum, product) => sum + (product.totalPrice ?? 0));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'receiptDate': receiptDate.toIso8601String(), // Conversion en ISO string
      'products': products.map((product) => product.toJson()).toList(),
      'totalAmount': totalAmount,
      if (userId != null) 'userId': userId,
    };
  }
}

extension ProductExtension on Product {
  Map<String, dynamic> toJson() {
    return {
      'productName': description, // Correspond au backend
      'unitPrice': unitPrice ?? 0.0, // Requis dans le backend
      if (quantity != null) 'quantity': quantity,
      if (totalPrice != null) 'totalPrice': totalPrice,
    };
  }

  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      description: json['productName'] ?? 'Produit inconnu', // Correspond au backend
      quantity: _parseDouble(json['quantity']),
      unitPrice: _parseDouble(json['unitPrice']) ?? 0.0, // Requis dans le backend
      totalPrice: _parseDouble(json['totalPrice']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}