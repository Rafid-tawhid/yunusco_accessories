// ============================================
// ITEMS MODEL - Represents a single product/item
// ============================================

import 'dart:ui';

import 'package:flutter/material.dart';

class ItemsModel {
  // Properties with better naming and nullable types
  final int? itemId;
  final String? itemRef;
  final dynamic option;
  final String? itemName;
  final String? productName;
  final String? size;
  final double? basicPrice;
  final DateTime? approvedDate;
  final String? sampleNo;
  final String? rbo;
  final String? pifFilePath;
  final String? isFixItem;
  final String? remarks;
  final bool? hasItemVariablePrice;
  final String? productLineName;
  final String? isActive;
  final String? isBlur;
  final bool? pifCreated;
  final DateTime? createDate;
  final int? costingRequestId;
  final int? type;
  final int? prodInfoId;
  final String? materialDesc;
  final int? uom;
  final String? uomName;

  // Constructor
  ItemsModel({
    this.itemId,
    this.itemRef,
    this.option,
    this.itemName,
    this.productName,
    this.size,
    this.basicPrice,
    this.approvedDate,
    this.sampleNo,
    this.rbo,
    this.pifFilePath,
    this.isFixItem,
    this.remarks,
    this.hasItemVariablePrice,
    this.productLineName,
    this.isActive,
    this.isBlur,
    this.pifCreated,
    this.createDate,
    this.costingRequestId,
    this.type,
    this.prodInfoId,
    this.materialDesc,
    this.uom,
    this.uomName,
  });

  // ============================================
  // FROM JSON - Creates model from API response
  // ============================================
  factory ItemsModel.fromJson(Map<String, dynamic> json) {
    return ItemsModel(
      itemId: json['ItemId'] as int?,
      itemRef: json['ItemRef'] as String?,
      option: json['Option'],
      itemName: json['ItemName'] as String?,
      productName: json['ProductName'] as String?,
      size: json['Size'] as String?,
      basicPrice: _parseDouble(json['BasicPrice']),
      approvedDate: _parseDate(json['ApprovedDate']),
      sampleNo: json['SampleNo'] as String?,
      rbo: json['RBO'] as String?,
      pifFilePath: json['PIFFilePath'] as String?,
      isFixItem: json['IsFixItem'] as String?,
      remarks: json['Remarks'] as String?,
      hasItemVariablePrice: json['HasItemVariablePrice'] as bool?,
      productLineName: json['ProductLineName'] as String?,
      isActive: json['IsActive'] as String?,
      isBlur: json['IsBlur'] as String?,
      pifCreated: json['PIFcreated'] as bool?,
      createDate: _parseDate(json['CreateDate']),
      costingRequestId: json['CostingRequestId'] as int?,
      type: json['Type'] as int?,
      prodInfoId: json['ProdInfoId'] as int?,
      materialDesc: json['MaterialDesc'] as String?,
      uom: json['Uom'] as int?,
      uomName: json['UomName'] as String?,
    );
  }

  // Helper: Convert to double safely
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Helper: Convert to DateTime safely
  static DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // TO JSON - Converts model to API format
  // ============================================
  Map<String, dynamic> toJson() {
    return {
      'ItemId': itemId,
      'ItemRef': itemRef,
      'Option': option,
      'ItemName': itemName,
      'ProductName': productName,
      'Size': size,
      'BasicPrice': basicPrice,
      'ApprovedDate': approvedDate?.toIso8601String(),
      'SampleNo': sampleNo,
      'RBO': rbo,
      'PIFFilePath': pifFilePath,
      'IsFixItem': isFixItem,
      'Remarks': remarks,
      'HasItemVariablePrice': hasItemVariablePrice,
      'ProductLineName': productLineName,
      'IsActive': isActive,
      'IsBlur': isBlur,
      'PIFcreated': pifCreated,
      'CreateDate': createDate?.toIso8601String(),
      'CostingRequestId': costingRequestId,
      'Type': type,
      'ProdInfoId': prodInfoId,
      'MaterialDesc': materialDesc,
      'Uom': uom,
      'UomName': uomName,
    };
  }

  // ============================================
  // COPY WITH - Creates a copy with changes
  // ============================================
  ItemsModel copyWith({
    int? itemId,
    String? itemRef,
    dynamic option,
    String? itemName,
    String? productName,
    String? size,
    double? basicPrice,
    DateTime? approvedDate,
    String? sampleNo,
    String? rbo,
    String? pifFilePath,
    String? isFixItem,
    String? remarks,
    bool? hasItemVariablePrice,
    String? productLineName,
    String? isActive,
    String? isBlur,
    bool? pifCreated,
    DateTime? createDate,
    int? costingRequestId,
    int? type,
    int? prodInfoId,
    String? materialDesc,
    int? uom,
    String? uomName,
  }) {
    return ItemsModel(
      itemId: itemId ?? this.itemId,
      itemRef: itemRef ?? this.itemRef,
      option: option ?? this.option,
      itemName: itemName ?? this.itemName,
      productName: productName ?? this.productName,
      size: size ?? this.size,
      basicPrice: basicPrice ?? this.basicPrice,
      approvedDate: approvedDate ?? this.approvedDate,
      sampleNo: sampleNo ?? this.sampleNo,
      rbo: rbo ?? this.rbo,
      pifFilePath: pifFilePath ?? this.pifFilePath,
      isFixItem: isFixItem ?? this.isFixItem,
      remarks: remarks ?? this.remarks,
      hasItemVariablePrice: hasItemVariablePrice ?? this.hasItemVariablePrice,
      productLineName: productLineName ?? this.productLineName,
      isActive: isActive ?? this.isActive,
      isBlur: isBlur ?? this.isBlur,
      pifCreated: pifCreated ?? this.pifCreated,
      createDate: createDate ?? this.createDate,
      costingRequestId: costingRequestId ?? this.costingRequestId,
      type: type ?? this.type,
      prodInfoId: prodInfoId ?? this.prodInfoId,
      materialDesc: materialDesc ?? this.materialDesc,
      uom: uom ?? this.uom,
      uomName: uomName ?? this.uomName,
    );
  }

  // ============================================
  // HELPER PROPERTIES for UI
  // ============================================

  // Get formatted price (with currency symbol)
  String get formattedPrice {
    if (basicPrice == null) return 'Price not available';
    return '৳ ${basicPrice!.toStringAsFixed(2)}';
  }

  // Get display name (prefers productName, falls back to itemName)
  String get displayName {
    return productName ?? itemName ?? 'Unnamed Item';
  }

  // Get short description for cards
  String get shortDescription {
    final parts = <String>[];
    if (size != null && size!.isNotEmpty) parts.add('Size: $size');
    if (uomName != null && uomName!.isNotEmpty) parts.add('UOM: $uomName');
    if (materialDesc != null && materialDesc!.isNotEmpty) parts.add(materialDesc!);
    return parts.isNotEmpty ? parts.join(' • ') : 'No description available';
  }

  // Check if item is active
  bool get isItemActive => isActive == 'true' || isActive == '1';

  // Get status text and color
  (String text, Color color) get status {
    if (isItemActive) {
      return ('Active', Colors.green);
    }
    return ('Inactive', Colors.red);
  }
}