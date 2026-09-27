class ItemReqDetailModel {
  const ItemReqDetailModel({
    this.materialRequisitionMasterId,
    this.requisitionNo,
    this.status,
    this.isLocked,
    this.submittedBy,
    this.decidedBy,
    this.decidedDate,
    this.rejectReason,
    this.details = const [],
  });

  final num? materialRequisitionMasterId;
  final String? requisitionNo;
  final num? status;
  final bool? isLocked;
  final String? submittedBy;
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
      status: _asNum(masterJson['Status']),
      isLocked: masterJson['IsLocked'] as bool?,
      submittedBy: _asString(masterJson['SubmittedBy']),
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
  });

  final num? materialRequisitionDetailsId;
  final String? itemId;
  final String? itemName;
  final String? buyerId;
  final String? buyerName;
  final num? quantity;
  final String? unitId;
  final num? lineNo;

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

num? _asNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '');
}

String? _asString(dynamic value) => value?.toString();
