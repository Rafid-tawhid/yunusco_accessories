class CustomerProfileDetailModel {
  final num? customerId;
  final String? customerCode;
  final String? customerName;
  final num? customerGroupId;

  final String? billToCompanyName;
  final String? billToAddressLine1;
  final String? billToAddressLine2;
  final String? billToContactPerson;
  final String? billToCellNo;
  final String? billToTelephone;

  final String? customerEmail;

  final String? shipToCompanyName;
  final String? shipToAddressLine1;
  final String? shipToAddressLine2;
  final String? shipToContactPerson;
  final String? shipToCellNo;
  final String? shipToTelephone;

  final String? createdDate;
  final num? createdBy;
  final num? creditLimit;
  final String? paymentMode;
  final String? majorProduct;
  final String? majorBrands;
  final num? totalCapacity;
  final num? totalEmployment;

  final String? boardOfDirectors;
  final String? merchandiseDepartment;
  final String? commercialDepartment;
  final String? accountsDepartment;
  final String? sisterConcern;
  final String? clientHistory;
  final String? managementRemarks;

  final num? approvedBy;
  final String? approvedDate;
  final num? rejectedBy;
  final String? rejectedDate;

  final bool? isForeign;
  final bool? isDiscountEligible;
  final bool? isConfirm;

  final String? signedCpFileName;
  final String? cpConfirmedDate;
  final String? bankAccount;
  final num? maxDiscountAmount;
  final num? discountPercentage;

  CustomerProfileDetailModel({
    this.customerId,
    this.customerCode,
    this.customerName,
    this.customerGroupId,
    this.billToCompanyName,
    this.billToAddressLine1,
    this.billToAddressLine2,
    this.billToContactPerson,
    this.billToCellNo,
    this.billToTelephone,
    this.customerEmail,
    this.shipToCompanyName,
    this.shipToAddressLine1,
    this.shipToAddressLine2,
    this.shipToContactPerson,
    this.shipToCellNo,
    this.shipToTelephone,
    this.createdDate,
    this.createdBy,
    this.creditLimit,
    this.paymentMode,
    this.majorProduct,
    this.majorBrands,
    this.totalCapacity,
    this.totalEmployment,
    this.boardOfDirectors,
    this.merchandiseDepartment,
    this.commercialDepartment,
    this.accountsDepartment,
    this.sisterConcern,
    this.clientHistory,
    this.managementRemarks,
    this.approvedBy,
    this.approvedDate,
    this.rejectedBy,
    this.rejectedDate,
    this.isForeign,
    this.isDiscountEligible,
    this.isConfirm,
    this.signedCpFileName,
    this.cpConfirmedDate,
    this.bankAccount,
    this.maxDiscountAmount,
    this.discountPercentage,
  });

  factory CustomerProfileDetailModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileDetailModel(
      customerId: json['YTA_CustomerId'],
      customerCode: json['YTA_CustomerCode'],
      customerName: json['YTA_CustomerName'],
      customerGroupId: json['YTA_CustomerGroupId'],
      billToCompanyName: json['YTA_BillToCompanyName'],
      billToAddressLine1: json['YTA_BillToAddressLine1'],
      billToAddressLine2: json['YTA_BillToAddressLine2'],
      billToContactPerson: json['YTA_BillToContactPerson'],
      billToCellNo: json['YTA_BillToCellNo'],
      billToTelephone: json['YTA_BillToTelephone'],
      customerEmail: json['YTA_CustomerEmail'],
      shipToCompanyName: json['YTA_ShipToCompanyName'],
      shipToAddressLine1: json['YTA_ShipToAddressLine1'],
      shipToAddressLine2: json['YTA_ShipToAddressLine2'],
      shipToContactPerson: json['YTA_ShipToContactPerson'],
      shipToCellNo: json['YTA_ShipToCellNo'],
      shipToTelephone: json['YTA_ShipToTelephone'],
      createdDate: _parseDate(json['YTA_CreatedDate']),
      createdBy: json['YTA_CreatedBy'],
      creditLimit: json['YTA_CreditLimit'],
      paymentMode: json['YTA_PaymentMode'],
      majorProduct: json['YTA_MajorProduct'],
      majorBrands: json['YTA_MajorBrands'],
      totalCapacity: json['YTA_TotalCapacity'],
      totalEmployment: json['YTA_TotalEmployment'],
      boardOfDirectors: json['YTA_BordOfDirectors'],
      merchandiseDepartment: json['YTA_MerchandiseDepartment'],
      commercialDepartment: json['YTA_CommercialDepartment'],
      accountsDepartment: json['YTA_AccountsDepartment'],
      sisterConcern: json['YTA_SisterConcern'],
      clientHistory: json['YTA_ClientHistory'],
      managementRemarks: json['YTA_ManagementRemarks'],
      approvedBy: json['YTA_ApprovedBy'],
      approvedDate: _parseDate(json['YTA_ApprovedDate']),
      rejectedBy: json['YTA_RejectedBy'],
      rejectedDate: _parseDate(json['YTA_RejectedDate']),
      isForeign: json['YTA_IsForeign'],
      isDiscountEligible: json['YTA_IsDiscountEligible'],
      isConfirm: json['IsConfirm'],
      signedCpFileName: json['YTA_SignedCpFileName'],
      cpConfirmedDate: _parseDate(json['YTA_CpConfirmedDate']),
      bankAccount: json['YTA_BankAccount'],
      maxDiscountAmount: json['YTA_MaxDiscountAmount'],
      discountPercentage: json['YTA_DiscountPercentage'],
    );
  }

  static String? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.startsWith('/Date(')) {
      final ms = int.tryParse(
        value.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (ms == null) return value;
      return DateTime.fromMillisecondsSinceEpoch(ms).toString().split(' ')[0];
    }
    return value.toString();
  }
}