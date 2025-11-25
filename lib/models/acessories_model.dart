class GarmentAccessory {
  final String id;
  final String name;
  final String type;
  final String material;
  final String composition;
  final String size;
  final String dimensions;
  final String color;
  final String weight;
  final String thickness;
  final String length;
  final String width;
  final String diameter;
  final String pattern;
  final String finish;
  final String brand;
  final String unit;
  final double price;
  final int quantity;
  final String supplier;
  final String supplierCode;
  final String description;
  final String usage;
  final String careInstructions;
  final String countryOfOrigin;
  final String qualityGrade;
  final bool isWashable;
  final bool isEcoFriendly;

  GarmentAccessory({
    required this.id,
    required this.name,
    required this.type,
    required this.material,
    required this.composition,
    required this.size,
    required this.dimensions,
    required this.color,
    required this.weight,
    required this.thickness,
    required this.length,
    required this.width,
    required this.diameter,
    required this.pattern,
    required this.finish,
    required this.brand,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.supplier,
    required this.supplierCode,
    required this.description,
    required this.usage,
    required this.careInstructions,
    required this.countryOfOrigin,
    required this.qualityGrade,
    required this.isWashable,
    required this.isEcoFriendly,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'material': material,
      'composition': composition,
      'size': size,
      'dimensions': dimensions,
      'color': color,
      'weight': weight,
      'thickness': thickness,
      'length': length,
      'width': width,
      'diameter': diameter,
      'pattern': pattern,
      'finish': finish,
      'brand': brand,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'supplier': supplier,
      'supplierCode': supplierCode,
      'description': description,
      'usage': usage,
      'careInstructions': careInstructions,
      'countryOfOrigin': countryOfOrigin,
      'qualityGrade': qualityGrade,
      'isWashable': isWashable,
      'isEcoFriendly': isEcoFriendly,
    };
  }


  factory GarmentAccessory.fromJson(Map<String, dynamic> json) {
    return GarmentAccessory(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      material: json['material'] as String? ?? '',
      composition: json['composition'] as String? ?? '',
      size: json['size'] as String? ?? '',
      dimensions: json['dimensions'] as String? ?? '',
      color: json['color'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      thickness: json['thickness'] as String? ?? '',
      length: json['length'] as String? ?? '',
      width: json['width'] as String? ?? '',
      diameter: json['diameter'] as String? ?? '',
      pattern: json['pattern'] as String? ?? '',
      finish: json['finish'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: (json['quantity'] is int)
          ? json['quantity'] as int
          : int.tryParse(json['quantity'].toString()) ?? 0,
      supplier: json['supplier'] as String? ?? '',
      supplierCode: json['supplierCode'] as String? ?? '',
      description: json['description'] as String? ?? '',
      usage: json['usage'] as String? ?? '',
      careInstructions: json['careInstructions'] as String? ?? '',
      countryOfOrigin: json['countryOfOrigin'] as String? ?? '',
      qualityGrade: json['qualityGrade'] as String? ?? '',
      isWashable: json['isWashable'] as bool? ?? false,
      isEcoFriendly: json['isEcoFriendly'] as bool? ?? false,
    );
  }
}