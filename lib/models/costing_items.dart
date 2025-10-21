class CostingItems {
  CostingItems({
      num? hMItemPriceId, 
      String? itemRef, 
      String? dimension, 
      dynamic part, 
      num? price, 
      bool? active, 
      String? remarks, 
      num? uom, 
      String? uomName,}){
    _hMItemPriceId = hMItemPriceId;
    _itemRef = itemRef;
    _dimension = dimension;
    _part = part;
    _price = price;
    _active = active;
    _remarks = remarks;
    _uom = uom;
    _uomName = uomName;
}

  CostingItems.fromJson(dynamic json) {
    _hMItemPriceId = json['HMItemPriceId'];
    _itemRef = json['ItemRef'];
    _dimension = json['Dimension'];
    _part = json['Part'];
    _price = json['Price'];
    _active = json['Active'];
    _remarks = json['Remarks'];
    _uom = json['Uom'];
    _uomName = json['UomName'];
  }
  num? _hMItemPriceId;
  String? _itemRef;
  String? _dimension;
  dynamic _part;
  num? _price;
  bool? _active;
  String? _remarks;
  num? _uom;
  String? _uomName;
CostingItems copyWith({  num? hMItemPriceId,
  String? itemRef,
  String? dimension,
  dynamic part,
  num? price,
  bool? active,
  String? remarks,
  num? uom,
  String? uomName,
}) => CostingItems(  hMItemPriceId: hMItemPriceId ?? _hMItemPriceId,
  itemRef: itemRef ?? _itemRef,
  dimension: dimension ?? _dimension,
  part: part ?? _part,
  price: price ?? _price,
  active: active ?? _active,
  remarks: remarks ?? _remarks,
  uom: uom ?? _uom,
  uomName: uomName ?? _uomName,
);
  num? get hMItemPriceId => _hMItemPriceId;
  String? get itemRef => _itemRef;
  String? get dimension => _dimension;
  dynamic get part => _part;
  num? get price => _price;
  bool? get active => _active;
  String? get remarks => _remarks;
  num? get uom => _uom;
  String? get uomName => _uomName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['HMItemPriceId'] = _hMItemPriceId;
    map['ItemRef'] = _itemRef;
    map['Dimension'] = _dimension;
    map['Part'] = _part;
    map['Price'] = _price;
    map['Active'] = _active;
    map['Remarks'] = _remarks;
    map['Uom'] = _uom;
    map['UomName'] = _uomName;
    return map;
  }

}