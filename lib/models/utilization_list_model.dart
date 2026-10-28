class UtilizationListModel {
  UtilizationListModel({
      this.utilizationId, 
      this.itemId, 
      this.itemName, 
      this.itemRef, 
      this.totalExistingStock, 
      this.totalNewOrder, 
      this.inHandQuantity, 
      this.haveToPrintQuantity, 
      this.remarks, 
      this.createdBy, 
      this.createdDate, 
      this.createdDateText, 
      this.isConfirm, 
      this.isMgntApproved,});

  UtilizationListModel.fromJson(dynamic json) {
    utilizationId = json['UtilizationId'];
    itemId = json['ItemId'];
    itemName = json['ItemName'];
    itemRef = json['ItemRef'];
    totalExistingStock = json['TotalExistingStock'];
    totalNewOrder = json['TotalNewOrder'];
    inHandQuantity = json['InHandQuantity'];
    haveToPrintQuantity = json['HaveToPrintQuantity'];
    remarks = json['Remarks'];
    createdBy = json['CreatedBy'];
    createdDate = json['CreatedDate'];
    createdDateText = json['CreatedDateText'];
    isConfirm = json['IsConfirm'];
    isMgntApproved = json['IsMgntApproved'];
  }
  num? utilizationId;
  num? itemId;
  String? itemName;
  String? itemRef;
  num? totalExistingStock;
  num? totalNewOrder;
  num? inHandQuantity;
  num? haveToPrintQuantity;
  String? remarks;
  String? createdBy;
  String? createdDate;
  String? createdDateText;
  bool? isConfirm;
  bool? isMgntApproved;
UtilizationListModel copyWith({  num? utilizationId,
  num? itemId,
  String? itemName,
  String? itemRef,
  num? totalExistingStock,
  num? totalNewOrder,
  num? inHandQuantity,
  num? haveToPrintQuantity,
  String? remarks,
  String? createdBy,
  String? createdDate,
  String? createdDateText,
  bool? isConfirm,
  bool? isMgntApproved,
}) => UtilizationListModel(  utilizationId: utilizationId ?? this.utilizationId,
  itemId: itemId ?? this.itemId,
  itemName: itemName ?? this.itemName,
  itemRef: itemRef ?? this.itemRef,
  totalExistingStock: totalExistingStock ?? this.totalExistingStock,
  totalNewOrder: totalNewOrder ?? this.totalNewOrder,
  inHandQuantity: inHandQuantity ?? this.inHandQuantity,
  haveToPrintQuantity: haveToPrintQuantity ?? this.haveToPrintQuantity,
  remarks: remarks ?? this.remarks,
  createdBy: createdBy ?? this.createdBy,
  createdDate: createdDate ?? this.createdDate,
  createdDateText: createdDateText ?? this.createdDateText,
  isConfirm: isConfirm ?? this.isConfirm,
  isMgntApproved: isMgntApproved ?? this.isMgntApproved,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['UtilizationId'] = utilizationId;
    map['ItemId'] = itemId;
    map['ItemName'] = itemName;
    map['ItemRef'] = itemRef;
    map['TotalExistingStock'] = totalExistingStock;
    map['TotalNewOrder'] = totalNewOrder;
    map['InHandQuantity'] = inHandQuantity;
    map['HaveToPrintQuantity'] = haveToPrintQuantity;
    map['Remarks'] = remarks;
    map['CreatedBy'] = createdBy;
    map['CreatedDate'] = createdDate;
    map['CreatedDateText'] = createdDateText;
    map['IsConfirm'] = isConfirm;
    map['IsMgntApproved'] = isMgntApproved;
    return map;
  }

}