import 'package:flutter/material.dart';
import 'package:eco_home_app/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${product.id}'),
        ),
        title: Text(product.name),
        subtitle: Text('Creado por: ${product.creatorName ?? 'Anónimo'}'),
        trailing: Text('\$${product.price.toStringAsFixed(2)}'),
      ),
    );
  }
}