class Product {
  final int id;
  final String name;
  final double price;
  final int? createdBy;
  final String? creatorName;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.createdBy,
    this.creatorName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      createdBy: json['created_by'],
      creatorName: json['creator_name'] ?? 'Anónimo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}