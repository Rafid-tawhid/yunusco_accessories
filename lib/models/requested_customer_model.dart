class RequestedCustomerModel {
  RequestedCustomerModel({
      this.yTACustomerId, 
      this.yTACustomerCode, 
      this.yTACustomerName, 
      this.yTACustomerGroupId, 
      this.yTABillToCompanyName, 
      this.yTABillToContactPerson, 
      this.yTABillToCellNo, 
      this.yTABillToTelephone, 
      this.yTACustomerEmail, 
      this.yTAShipToCompanyName, 
      this.yTAShipToContactPerson, 
      this.yTAShipToCellNo, 
      this.yTACreatedDate, 
      this.yTACreatedBy, 
      this.yTACreditLimit, 
      this.yTAAccountCode, 
      this.yTAPaymentMode, 
      this.yTAMajorProduct, 
      this.yTAMajorBrands, 
      this.yTAIsForeign, 
      this.yTAIsDiscountEligible, 
      this.yTAApprovedBy, 
      this.yTAApprovedDate, 
      this.isConfirm, 
      this.isConfirmManagement,});

  RequestedCustomerModel.fromJson(dynamic json) {
    yTACustomerId = json['YTA_CustomerId'];
    yTACustomerCode = json['YTA_CustomerCode'];
    yTACustomerName = json['YTA_CustomerName'];
    yTACustomerGroupId = json['YTA_CustomerGroupId'];
    yTABillToCompanyName = json['YTA_BillToCompanyName'];
    yTABillToContactPerson = json['YTA_BillToContactPerson'];
    yTABillToCellNo = json['YTA_BillToCellNo'];
    yTABillToTelephone = json['YTA_BillToTelephone'];
    yTACustomerEmail = json['YTA_CustomerEmail'];
    yTAShipToCompanyName = json['YTA_ShipToCompanyName'];
    yTAShipToContactPerson = json['YTA_ShipToContactPerson'];
    yTAShipToCellNo = json['YTA_ShipToCellNo'];
    yTACreatedDate = json['YTA_CreatedDate'];
    yTACreatedBy = json['YTA_CreatedBy'];
    yTACreditLimit = json['YTA_CreditLimit'];
    yTAAccountCode = json['YTA_AccountCode'];
    yTAPaymentMode = json['YTA_PaymentMode'];
    yTAMajorProduct = json['YTA_MajorProduct'];
    yTAMajorBrands = json['YTA_MajorBrands'];
    yTAIsForeign = json['YTA_IsForeign'];
    yTAIsDiscountEligible = json['YTA_IsDiscountEligible'];
    yTAApprovedBy = json['YTA_ApprovedBy'];
    yTAApprovedDate = json['YTA_ApprovedDate'];
    isConfirm = json['IsConfirm'];
    isConfirmManagement = json['IsConfirmManagement'];
  }
  num? yTACustomerId;
  dynamic yTACustomerCode;
  String? yTACustomerName;
  num? yTACustomerGroupId;
  String? yTABillToCompanyName;
  String? yTABillToContactPerson;
  String? yTABillToCellNo;
  String? yTABillToTelephone;
  dynamic yTACustomerEmail;
  String? yTAShipToCompanyName;
  String? yTAShipToContactPerson;
  String? yTAShipToCellNo;
  String? yTACreatedDate;
  num? yTACreatedBy;
  num? yTACreditLimit;
  dynamic yTAAccountCode;
  String? yTAPaymentMode;
  String? yTAMajorProduct;
  String? yTAMajorBrands;
  bool? yTAIsForeign;
  bool? yTAIsDiscountEligible;
  num? yTAApprovedBy;
  String? yTAApprovedDate;
  bool? isConfirm;
  dynamic isConfirmManagement;
RequestedCustomerModel copyWith({  num? yTACustomerId,
  dynamic yTACustomerCode,
  String? yTACustomerName,
  num? yTACustomerGroupId,
  String? yTABillToCompanyName,
  String? yTABillToContactPerson,
  String? yTABillToCellNo,
  String? yTABillToTelephone,
  dynamic yTACustomerEmail,
  String? yTAShipToCompanyName,
  String? yTAShipToContactPerson,
  String? yTAShipToCellNo,
  String? yTACreatedDate,
  num? yTACreatedBy,
  num? yTACreditLimit,
  dynamic yTAAccountCode,
  String? yTAPaymentMode,
  String? yTAMajorProduct,
  String? yTAMajorBrands,
  bool? yTAIsForeign,
  bool? yTAIsDiscountEligible,
  num? yTAApprovedBy,
  String? yTAApprovedDate,
  bool? isConfirm,
  dynamic isConfirmManagement,
}) => RequestedCustomerModel(  yTACustomerId: yTACustomerId ?? this.yTACustomerId,
  yTACustomerCode: yTACustomerCode ?? this.yTACustomerCode,
  yTACustomerName: yTACustomerName ?? this.yTACustomerName,
  yTACustomerGroupId: yTACustomerGroupId ?? this.yTACustomerGroupId,
  yTABillToCompanyName: yTABillToCompanyName ?? this.yTABillToCompanyName,
  yTABillToContactPerson: yTABillToContactPerson ?? this.yTABillToContactPerson,
  yTABillToCellNo: yTABillToCellNo ?? this.yTABillToCellNo,
  yTABillToTelephone: yTABillToTelephone ?? this.yTABillToTelephone,
  yTACustomerEmail: yTACustomerEmail ?? this.yTACustomerEmail,
  yTAShipToCompanyName: yTAShipToCompanyName ?? this.yTAShipToCompanyName,
  yTAShipToContactPerson: yTAShipToContactPerson ?? this.yTAShipToContactPerson,
  yTAShipToCellNo: yTAShipToCellNo ?? this.yTAShipToCellNo,
  yTACreatedDate: yTACreatedDate ?? this.yTACreatedDate,
  yTACreatedBy: yTACreatedBy ?? this.yTACreatedBy,
  yTACreditLimit: yTACreditLimit ?? this.yTACreditLimit,
  yTAAccountCode: yTAAccountCode ?? this.yTAAccountCode,
  yTAPaymentMode: yTAPaymentMode ?? this.yTAPaymentMode,
  yTAMajorProduct: yTAMajorProduct ?? this.yTAMajorProduct,
  yTAMajorBrands: yTAMajorBrands ?? this.yTAMajorBrands,
  yTAIsForeign: yTAIsForeign ?? this.yTAIsForeign,
  yTAIsDiscountEligible: yTAIsDiscountEligible ?? this.yTAIsDiscountEligible,
  yTAApprovedBy: yTAApprovedBy ?? this.yTAApprovedBy,
  yTAApprovedDate: yTAApprovedDate ?? this.yTAApprovedDate,
  isConfirm: isConfirm ?? this.isConfirm,
  isConfirmManagement: isConfirmManagement ?? this.isConfirmManagement,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['YTA_CustomerId'] = yTACustomerId;
    map['YTA_CustomerCode'] = yTACustomerCode;
    map['YTA_CustomerName'] = yTACustomerName;
    map['YTA_CustomerGroupId'] = yTACustomerGroupId;
    map['YTA_BillToCompanyName'] = yTABillToCompanyName;
    map['YTA_BillToContactPerson'] = yTABillToContactPerson;
    map['YTA_BillToCellNo'] = yTABillToCellNo;
    map['YTA_BillToTelephone'] = yTABillToTelephone;
    map['YTA_CustomerEmail'] = yTACustomerEmail;
    map['YTA_ShipToCompanyName'] = yTAShipToCompanyName;
    map['YTA_ShipToContactPerson'] = yTAShipToContactPerson;
    map['YTA_ShipToCellNo'] = yTAShipToCellNo;
    map['YTA_CreatedDate'] = yTACreatedDate;
    map['YTA_CreatedBy'] = yTACreatedBy;
    map['YTA_CreditLimit'] = yTACreditLimit;
    map['YTA_AccountCode'] = yTAAccountCode;
    map['YTA_PaymentMode'] = yTAPaymentMode;
    map['YTA_MajorProduct'] = yTAMajorProduct;
    map['YTA_MajorBrands'] = yTAMajorBrands;
    map['YTA_IsForeign'] = yTAIsForeign;
    map['YTA_IsDiscountEligible'] = yTAIsDiscountEligible;
    map['YTA_ApprovedBy'] = yTAApprovedBy;
    map['YTA_ApprovedDate'] = yTAApprovedDate;
    map['IsConfirm'] = isConfirm;
    map['IsConfirmManagement'] = isConfirmManagement;
    return map;
  }

}