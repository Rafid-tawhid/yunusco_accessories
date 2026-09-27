class ItemReqModel {
  ItemReqModel({
      this.materialRequisitionMasterId, 
      this.requisitionNo, 
      this.requisitionDate, 
      this.remarks, 
      this.totalQuantity, 
      this.status, 
      this.isLocked, 
      this.createdBy, 
      this.submittedBy, 
      this.createdDate,});

  ItemReqModel.fromJson(dynamic json) {
    materialRequisitionMasterId = json['MaterialRequisitionMasterId'];
    requisitionNo = json['RequisitionNo'];
    requisitionDate = json['RequisitionDate'];
    remarks = json['Remarks'];
    totalQuantity = json['TotalQuantity'];
    status = json['Status'];
    isLocked = json['IsLocked'];
    createdBy = json['CreatedBy'];
    submittedBy = json['SubmittedBy'];
    createdDate = json['CreatedDate'];
  }
  num? materialRequisitionMasterId;
  String? requisitionNo;
  String? requisitionDate;
  String? remarks;
  num? totalQuantity;
  num? status;
  bool? isLocked;
  dynamic createdBy;
  String? submittedBy;
  String? createdDate;
ItemReqModel copyWith({  num? materialRequisitionMasterId,
  String? requisitionNo,
  String? requisitionDate,
  String? remarks,
  num? totalQuantity,
  num? status,
  bool? isLocked,
  dynamic createdBy,
  String? submittedBy,
  String? createdDate,
}) => ItemReqModel(  materialRequisitionMasterId: materialRequisitionMasterId ?? this.materialRequisitionMasterId,
  requisitionNo: requisitionNo ?? this.requisitionNo,
  requisitionDate: requisitionDate ?? this.requisitionDate,
  remarks: remarks ?? this.remarks,
  totalQuantity: totalQuantity ?? this.totalQuantity,
  status: status ?? this.status,
  isLocked: isLocked ?? this.isLocked,
  createdBy: createdBy ?? this.createdBy,
  submittedBy: submittedBy ?? this.submittedBy,
  createdDate: createdDate ?? this.createdDate,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['MaterialRequisitionMasterId'] = materialRequisitionMasterId;
    map['RequisitionNo'] = requisitionNo;
    map['RequisitionDate'] = requisitionDate;
    map['Remarks'] = remarks;
    map['TotalQuantity'] = totalQuantity;
    map['Status'] = status;
    map['IsLocked'] = isLocked;
    map['CreatedBy'] = createdBy;
    map['SubmittedBy'] = submittedBy;
    map['CreatedDate'] = createdDate;
    return map;
  }

}