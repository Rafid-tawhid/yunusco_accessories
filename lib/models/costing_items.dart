// models/costing_model.dart
class CostingItem {
  final String id;
  final String category;
  final String productName;
  final String size;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String description;
  final DateTime createdAt;
  final String? imageUrl;

  CostingItem({
    required this.id,
    required this.category,
    required this.productName,
    required this.size,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.description,
    required this.createdAt,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'productName': productName,
      'size': size,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
    };
  }

  factory CostingItem.fromMap(Map<String, dynamic> map) {
    return CostingItem(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      productName: map['productName'] ?? '',
      size: map['size'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      unitPrice: map['unitPrice']?.toDouble() ?? 0.0,
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      imageUrl: map['imageUrl'],
    );
  }

  CostingItem copyWith({
    String? category,
    String? productName,
    String? size,
    int? quantity,
    double? unitPrice,
    String? description,
  }) {
    return CostingItem(
      id: id,
      category: category ?? this.category,
      productName: productName ?? this.productName,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: (quantity ?? this.quantity) * (unitPrice ?? this.unitPrice),
      description: description ?? this.description,
      createdAt: createdAt,
      imageUrl: imageUrl,
    );
  }
}