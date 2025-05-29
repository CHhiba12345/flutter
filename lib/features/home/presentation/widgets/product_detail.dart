import 'package:flutter/material.dart';

import '../../domain/entities/product.dart' show Product;

class ProductDetail extends StatelessWidget {
  final Product product;

  const ProductDetail({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // Votre app bar de détail...
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => Column(
                children: [
                  // Contenu du détail du produit...
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}