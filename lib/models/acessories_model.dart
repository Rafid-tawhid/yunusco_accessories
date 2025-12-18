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
  final String status;
  final String careInstructions;
  final String countryOfOrigin;
  final String qualityGrade;
  final String createdDate;
  final String modifiedDate;
  final bool isWashable;
  final bool isEcoFriendly;

  GarmentAccessory({
    required this.id, // ID can be set from outside
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
    required this.status,
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
    required this.createdDate,
    required this.modifiedDate,
  });

  // Factory constructor to create with auto-generated ID
  factory GarmentAccessory.createNew({
    required String name,
    required String type,
    required String material,
    required String composition,
    required String size,
    required String dimensions,
    required String color,
    required String weight,
    required String thickness,
    required String length,
    required String width,
    required String diameter,
    required String pattern,
    required String finish,
    required String brand,
    required String unit,
    required double price,
    required String status,
    required int quantity,
    required String supplier,
    required String supplierCode,
    required String description,
    required String usage,
    required String careInstructions,
    required String countryOfOrigin,
    required String qualityGrade,
    required bool isWashable,
    required bool isEcoFriendly,
  }) {
    final now = DateTime.now().toIso8601String();
    return GarmentAccessory(
      id: '', // Empty ID - you can set it later with copyWith
      name: name,
      type: type,
      material: material,
      composition: composition,
      size: size,
      dimensions: dimensions,
      color: color,
      weight: weight,
      thickness: thickness,
      length: length,
      width: width,
      diameter: diameter,
      pattern: pattern,
      finish: finish,
      brand: brand,
      unit: unit,
      price: price,
      status: status,
      quantity: quantity,
      supplier: supplier,
      supplierCode: supplierCode,
      description: description,
      usage: usage,
      careInstructions: careInstructions,
      countryOfOrigin: countryOfOrigin,
      qualityGrade: qualityGrade,
      isWashable: isWashable,
      isEcoFriendly: isEcoFriendly,
      createdDate: now,
      modifiedDate: now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'material': material,
      'composition': composition,
      'size': size,
      'status': status,
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
      'createdDate': createdDate,
      'modifiedDate': modifiedDate,
    };
  }

  factory GarmentAccessory.fromJson(Map<String, dynamic> json) {
    return GarmentAccessory(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      createdDate: json['createdDate'] as String,
      modifiedDate: json['modifiedDate'] as String,
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

  // CopyWith method
  GarmentAccessory copyWith({
    String? id,
    String? name,
    String? type,
    String? material,
    String? composition,
    String? size,
    String? dimensions,
    String? color,
    String? weight,
    String? thickness,
    String? length,
    String? width,
    String? diameter,
    String? pattern,
    String? finish,
    String? brand,
    String? unit,
    double? price,
    int? quantity,
    String? supplier,
    String? supplierCode,
    String? description,
    String? usage,
    String? status,
    String? careInstructions,
    String? countryOfOrigin,
    String? qualityGrade,
    String? createdDate,
    String? modifiedDate,
    bool? isWashable,
    bool? isEcoFriendly,
  }) {
    return GarmentAccessory(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      material: material ?? this.material,
      composition: composition ?? this.composition,
      size: size ?? this.size,
      dimensions: dimensions ?? this.dimensions,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      thickness: thickness ?? this.thickness,
      length: length ?? this.length,
      width: width ?? this.width,
      diameter: diameter ?? this.diameter,
      pattern: pattern ?? this.pattern,
      finish: finish ?? this.finish,
      brand: brand ?? this.brand,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      supplier: supplier ?? this.supplier,
      supplierCode: supplierCode ?? this.supplierCode,
      description: description ?? this.description,
      usage: usage ?? this.usage,
      status: status ?? this.status,
      careInstructions: careInstructions ?? this.careInstructions,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      isWashable: isWashable ?? this.isWashable,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
    );
  }

  // Helper method to update modified date
  GarmentAccessory withModifiedDate() {
    return copyWith(modifiedDate: DateTime.now().toIso8601String());
  }
}