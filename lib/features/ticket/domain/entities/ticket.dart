import 'package:flutter/foundation.dart';

class Ticket {
  final String storeName;
  final String receiptDate;
  final List<Product> products;
  final double totalAmount;
  final String? userId;

  Ticket({
    required this.storeName,
    required this.receiptDate,
    required this.products,
    required this.totalAmount,
    this.userId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final productsList = (json['products'] as List)
        .map((productJson) => Product.fromJson(productJson))
        .toList();

    return Ticket(
      storeName: json['storeName'] ?? 'Unknown store',
      receiptDate: _parseDate(json['receiptDate']),
      products: productsList,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? _calculateTotalFromProducts(productsList),
      userId: json['userId'],
    );
  }

  static String _parseDate(dynamic value) {
    if (value == null || value.toString().toLowerCase() == 'unknown date') {
      return DateTime.now().toIso8601String(); // Date actuelle si inconnue
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed.toIso8601String();

      // Si le format est JJ/MM/YYYY, on convertit
      final parts = value.split('/');
      if (parts.length == 3) {
        final day = parts[0];
        final month = parts[1];
        final year = parts[2];
        final correctedFormat = '$year-$month-$day';
        final date = DateTime.tryParse(correctedFormat);
        if (date != null) return date.toIso8601String();
      }
    }

    return DateTime.now().toIso8601String(); // Fallback à la date actuelle
  }

  static double _calculateTotalFromProducts(List<Product> products) {
    return products.fold(0.0, (sum, product) => sum + (product.totalPrice ?? 0));
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'receiptDate': receiptDate,
      'products': products.map((product) => product.toJson()).toList(),
      'totalAmount': totalAmount,
      if (userId != null) 'userId': userId,
    };
  }
}

class Product {
  final String description;
  final double? quantity;
  final double? unitPrice;
  final double? totalPrice;

  Product({
    required this.description,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      description: json['productName'] ?? 'Unknown product',
      quantity: _parseDouble(json['quantity']),
      unitPrice: _parseDouble(json['unitPrice']) ?? 0.0,
      totalPrice: _parseDouble(json['totalPrice']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': description,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unitPrice': unitPrice,
      if (totalPrice != null) 'totalPrice': totalPrice,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}