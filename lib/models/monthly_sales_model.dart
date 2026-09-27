class MonthlySalesModel {
  MonthlySalesModel({
    this.orderYrMn,
    this.orderQuantity,
    this.orderValue,
    this.deliveredQuantity,
    this.deliveredValue,
  });

  factory MonthlySalesModel.fromJson(dynamic json) {
    final map = json is Map
        ? json as Map<String, dynamic>
        : <String, dynamic>{};
    return MonthlySalesModel(
      orderYrMn: map['OrderYrMn']?.toString(),
      orderQuantity: _toNum(map['OrderQuantity']),
      orderValue: _toNum(map['OrderValue']),
      deliveredQuantity: _toNum(map['DeliveredQuantity']),
      deliveredValue: _toNum(map['DeliveredValue']),
    );
  }

  static num? _toNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }

  String? orderYrMn;
  num? orderQuantity;
  num? orderValue;
  num? deliveredQuantity;
  num? deliveredValue;

  MonthlySalesModel copyWith({
    String? orderYrMn,
    num? orderQuantity,
    num? orderValue,
    num? deliveredQuantity,
    num? deliveredValue,
  }) => MonthlySalesModel(
    orderYrMn: orderYrMn ?? this.orderYrMn,
    orderQuantity: orderQuantity ?? this.orderQuantity,
    orderValue: orderValue ?? this.orderValue,
    deliveredQuantity: deliveredQuantity ?? this.deliveredQuantity,
    deliveredValue: deliveredValue ?? this.deliveredValue,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['OrderYrMn'] = orderYrMn;
    map['OrderQuantity'] = orderQuantity;
    map['OrderValue'] = orderValue;
    map['DeliveredQuantity'] = deliveredQuantity;
    map['DeliveredValue'] = deliveredValue;
    return map;
  }
}
