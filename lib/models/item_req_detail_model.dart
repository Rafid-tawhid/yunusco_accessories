class ItemReqDetailModel {
  const ItemReqDetailModel({
    this.materialRequisitionMasterId,
    this.requisitionNo,
    this.requisitionDate,
    this.remarks,
    this.totalQuantity,
    this.status,
    this.isLocked,
    this.createdBy,
    this.submittedBy,
    this.createdDate,
    this.decidedBy,
    this.decidedDate,
    this.rejectReason,
    this.details = const [],
  });

  final num? materialRequisitionMasterId;
  final String? requisitionNo;
  final String? requisitionDate;
  final String? remarks;
  final num? totalQuantity;
  final num? status;
  final bool? isLocked;
  final num? createdBy;
  final String? submittedBy;
  final String? createdDate;
  final String? decidedBy;
  final String? decidedDate;
  final String? rejectReason;
  final List<ItemReqLineModel> details;

  factory ItemReqDetailModel.fromJson(Map<String, dynamic> json) {
    final master = json['master'];
    final rows = json['details'];
    if (master is! Map || rows is! List) {
      throw const FormatException(
        'Requisition response must contain master and details',
      );
    }

    final masterJson = Map<String, dynamic>.from(master);
    return ItemReqDetailModel(
      materialRequisitionMasterId: _asNum(
        masterJson['MaterialRequisitionMasterId'],
      ),
      requisitionNo: _asString(masterJson['RequisitionNo']),
      requisitionDate: _asString(masterJson['RequisitionDate']),
      remarks: _asString(masterJson['Remarks']),
      totalQuantity: _asNum(masterJson['TotalQuantity']),
      status: _asNum(masterJson['Status']),
      isLocked: masterJson['IsLocked'] as bool?,
      createdBy: _asNum(masterJson['CreatedBy']),
      submittedBy: _asString(masterJson['SubmittedBy']),
      createdDate: _asString(masterJson['CreatedDate']),
      decidedBy: _asString(masterJson['DecidedBy']),
      decidedDate: _asString(masterJson['DecidedDate']),
      rejectReason: _asString(masterJson['RejectReason']),
      details: rows.map((row) {
        if (row is! Map) {
          throw const FormatException(
            'Requisition detail entries must be objects',
          );
        }
        return ItemReqLineModel.fromJson(Map<String, dynamic>.from(row));
      }).toList(),
    );
  }
}

class ItemReqLineModel {
  const ItemReqLineModel({
    this.materialRequisitionDetailsId,
    this.itemId,
    this.itemName,
    this.buyerId,
    this.buyerName,
    this.quantity,
    this.unitId,
    this.lineNo,
    this.createdByName,
    this.last6MonthsHistory = const [],
  });

  final num? materialRequisitionDetailsId;
  final String? itemId;
  final String? itemName;
  final String? buyerId;
  final String? buyerName;
  final num? quantity;
  final String? unitId;
  final num? lineNo;
  final String? createdByName;
  final List<ItemReqHistoryModel> last6MonthsHistory;

  factory ItemReqLineModel.fromJson(Map<String, dynamic> json) {
    return ItemReqLineModel(
      materialRequisitionDetailsId: _asNum(
        json['MaterialRequisitionDetailsId'],
      ),
      itemId: _asString(json['ItemId']),
      itemName: _asString(json['ItemName']),
      buyerId: _asString(json['BuyerId']),
      buyerName: _asString(json['BuyerName']),
      quantity: _asNum(json['Quantity']),
      unitId: _asString(json['UnitId']),
      lineNo: _asNum(json['LineNo']),
      createdByName: _asString(json['CreatedByName']),
      last6MonthsHistory: _parseHistory(json['Last6MonthsHistory']),
    );
  }
}

class ItemReqHistoryModel {
  const ItemReqHistoryModel({this.monthNo, this.yearNo, this.quantity});

  final num? monthNo;
  final num? yearNo;
  final num? quantity;


  factory ItemReqHistoryModel.fromJson(Map<String, dynamic> json) {
    return ItemReqHistoryModel(
      monthNo: _asNum(json['MonthNo']),
      yearNo: _asNum(json['YearNo']),
      quantity: _asNum(json['Quantity'])

    );
  }
}

class ItemReqDecisionRequest {
  const ItemReqDecisionRequest({
    required this.id,
    required this.decision,
    required this.comment,
    required this.decidedBy,
  });

  final num id;
  final String decision;
  final String comment;
  final String decidedBy;

  Map<String, dynamic> toJson() => {
    'id': id,
    'decision': decision,
    'comment': comment,
    'decidedBy': decidedBy,
  };
}

List<ItemReqHistoryModel> _parseHistory(dynamic value) {
  if (value == null) return const [];
  if (value is! List) {
    throw const FormatException('Item history must be a list');
  }
  return value.map((entry) {
    if (entry is! Map) {
      throw const FormatException('Item history entries must be objects');
    }
    return ItemReqHistoryModel.fromJson(Map<String, dynamic>.from(entry));
  }).toList();
}

num? _asNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '');
}

String? _asString(dynamic value) => value?.toString();
