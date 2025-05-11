import '../../domain/entities/ticket.dart';

class TicketModel extends Ticket {
  TicketModel({
    required String storeName,
    required String receiptDate,
    required List<Product> products,
    required double totalAmount,
    String? userId,
  }) : super(
    storeName: storeName,
    receiptDate: receiptDate,
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
      receiptDate: _parseDate(json['receiptDate']), // ✅ Bon nom + parsing
      products: productsList,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ??
          _calculateTotalFromProducts(productsList),
      userId: json['userId'],
    );
  }

  static String _parseDate(dynamic value) {
    if (value == null || value.toString().toLowerCase() == 'unknown date') {
      return DateTime.now().toUtc().toIso8601String(); // Force UTC + Z
    }

    if (value is DateTime) {
      return value.toUtc().toIso8601String(); // Toujours en UTC
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed.toUtc().toIso8601String();

      final parts = value.split('/');
      if (parts.length == 3) {
        final day = parts[0];
        final month = parts[1];
        final year = parts[2];
        final correctedFormat = '$year-$month-$day';
        final date = DateTime.tryParse(correctedFormat);
        if (date != null) return date.toUtc().toIso8601String();
      }
    }

    return DateTime.now().toUtc().toIso8601String(); // Fallback UTC
  }

  static double _calculateTotalFromProducts(List<Product> products) {
    return products.fold(0.0, (sum, product) => sum + (product.totalPrice ?? 0));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'receiptDate': receiptDate, // Déjà au bon format
      'products': products.map((product) => product.toJson()).toList(),
      'totalAmount': totalAmount,
      if (userId != null) 'userId': userId,
    };
  }
}

extension ProductExtension on Product {
  Map<String, dynamic> toJson() {
    return {
      'productName': description,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unitPrice': unitPrice,
      if (totalPrice != null) 'totalPrice': totalPrice,
    };
  }

  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      description: json['productName'] ?? 'Produit inconnu',
      quantity: _parseDouble(json['quantity']),
      unitPrice: _parseDouble(json['unitPrice']),
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