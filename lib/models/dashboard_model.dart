class DashboardModel {
  DashboardModel({
      this.monthlySales, 
      this.dailySales, 
      this.personWiseSales, 
      this.orderVsInvoice, 
      this.orderVsDelivery, 
      this.piVsLc, 
      this.categoryA, 
      this.categoryB, 
      this.categoryC, 
      this.categoryD, 
      this.rboWiseSales, 
      this.csWiseSales,});

  DashboardModel.fromJson(dynamic json) {
    if (json['monthlySales'] != null) {
      monthlySales = [];
      json['monthlySales'].forEach((v) {
        monthlySales?.add(MonthlySales.fromJson(v));
      });
    }
    if (json['dailySales'] != null) {
      dailySales = [];
      json['dailySales'].forEach((v) {
        dailySales?.add(DailySales.fromJson(v));
      });
    }
    if (json['personWiseSales'] != null) {
      personWiseSales = [];
      json['personWiseSales'].forEach((v) {
        personWiseSales?.add(PersonWiseSales.fromJson(v));
      });
    }
    if (json['orderVsInvoice'] != null) {
      orderVsInvoice = [];
      json['orderVsInvoice'].forEach((v) {
        orderVsInvoice?.add(OrderVsInvoice.fromJson(v));
      });
    }
    if (json['orderVsDelivery'] != null) {
      orderVsDelivery = [];
      json['orderVsDelivery'].forEach((v) {
        orderVsDelivery?.add(OrderVsDelivery.fromJson(v));
      });
    }
    if (json['piVsLc'] != null) {
      piVsLc = [];
      json['piVsLc'].forEach((v) {
        piVsLc?.add(PiVsLc.fromJson(v));
      });
    }
    if (json['categoryA'] != null) {
      categoryA = [];
      json['categoryA'].forEach((v) {
        categoryA?.add(CategoryA.fromJson(v));
      });
    }
    if (json['categoryB'] != null) {
      categoryB = [];
      json['categoryB'].forEach((v) {
        categoryB?.add(CategoryB.fromJson(v));
      });
    }
    if (json['categoryC'] != null) {
      categoryC = [];
      json['categoryC'].forEach((v) {
        categoryC?.add(CategoryC.fromJson(v));
      });
    }
    if (json['categoryD'] != null) {
      categoryD = [];
      json['categoryD'].forEach((v) {
        categoryD?.add(CategoryD.fromJson(v));
      });
    }
    if (json['rboWiseSales'] != null) {
      rboWiseSales = [];
      json['rboWiseSales'].forEach((v) {
        rboWiseSales?.add(RboWiseSales.fromJson(v));
      });
    }
    if (json['csWiseSales'] != null) {
      csWiseSales = [];
      json['csWiseSales'].forEach((v) {
        csWiseSales?.add(CsWiseSales.fromJson(v));
      });
    }
  }
  List<MonthlySales>? monthlySales;
  List<DailySales>? dailySales;
  List<PersonWiseSales>? personWiseSales;
  List<OrderVsInvoice>? orderVsInvoice;
  List<OrderVsDelivery>? orderVsDelivery;
  List<PiVsLc>? piVsLc;
  List<CategoryA>? categoryA;
  List<CategoryB>? categoryB;
  List<CategoryC>? categoryC;
  List<CategoryD>? categoryD;
  List<RboWiseSales>? rboWiseSales;
  List<CsWiseSales>? csWiseSales;
DashboardModel copyWith({  List<MonthlySales>? monthlySales,
  List<DailySales>? dailySales,
  List<PersonWiseSales>? personWiseSales,
  List<OrderVsInvoice>? orderVsInvoice,
  List<OrderVsDelivery>? orderVsDelivery,
  List<PiVsLc>? piVsLc,
  List<CategoryA>? categoryA,
  List<CategoryB>? categoryB,
  List<CategoryC>? categoryC,
  List<CategoryD>? categoryD,
  List<RboWiseSales>? rboWiseSales,
  List<CsWiseSales>? csWiseSales,
}) => DashboardModel(  monthlySales: monthlySales ?? this.monthlySales,
  dailySales: dailySales ?? this.dailySales,
  personWiseSales: personWiseSales ?? this.personWiseSales,
  orderVsInvoice: orderVsInvoice ?? this.orderVsInvoice,
  orderVsDelivery: orderVsDelivery ?? this.orderVsDelivery,
  piVsLc: piVsLc ?? this.piVsLc,
  categoryA: categoryA ?? this.categoryA,
  categoryB: categoryB ?? this.categoryB,
  categoryC: categoryC ?? this.categoryC,
  categoryD: categoryD ?? this.categoryD,
  rboWiseSales: rboWiseSales ?? this.rboWiseSales,
  csWiseSales: csWiseSales ?? this.csWiseSales,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (monthlySales != null) {
      map['monthlySales'] = monthlySales?.map((v) => v.toJson()).toList();
    }
    if (dailySales != null) {
      map['dailySales'] = dailySales?.map((v) => v.toJson()).toList();
    }
    if (personWiseSales != null) {
      map['personWiseSales'] = personWiseSales?.map((v) => v.toJson()).toList();
    }
    if (orderVsInvoice != null) {
      map['orderVsInvoice'] = orderVsInvoice?.map((v) => v.toJson()).toList();
    }
    if (orderVsDelivery != null) {
      map['orderVsDelivery'] = orderVsDelivery?.map((v) => v.toJson()).toList();
    }
    if (piVsLc != null) {
      map['piVsLc'] = piVsLc?.map((v) => v.toJson()).toList();
    }
    if (categoryA != null) {
      map['categoryA'] = categoryA?.map((v) => v.toJson()).toList();
    }
    if (categoryB != null) {
      map['categoryB'] = categoryB?.map((v) => v.toJson()).toList();
    }
    if (categoryC != null) {
      map['categoryC'] = categoryC?.map((v) => v.toJson()).toList();
    }
    if (categoryD != null) {
      map['categoryD'] = categoryD?.map((v) => v.toJson()).toList();
    }
    if (rboWiseSales != null) {
      map['rboWiseSales'] = rboWiseSales?.map((v) => v.toJson()).toList();
    }
    if (csWiseSales != null) {
      map['csWiseSales'] = csWiseSales?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class CsWiseSales {
  CsWiseSales({
      this.label, 
      this.value,});

  CsWiseSales.fromJson(dynamic json) {
    label = json['label'];
    value = json['value'];
  }
  String? label;
  num? value;
CsWiseSales copyWith({  String? label,
  num? value,
}) => CsWiseSales(  label: label ?? this.label,
  value: value ?? this.value,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['label'] = label;
    map['value'] = value;
    return map;
  }

}

class RboWiseSales {
  RboWiseSales({
      this.label, 
      this.value,});

  RboWiseSales.fromJson(dynamic json) {
    label = json['label'];
    value = json['value'];
  }
  String? label;
  num? value;
RboWiseSales copyWith({  String? label,
  num? value,
}) => RboWiseSales(  label: label ?? this.label,
  value: value ?? this.value,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['label'] = label;
    map['value'] = value;
    return map;
  }

}

class CategoryD {
  CategoryD({
      this.label, 
      this.value,});

  CategoryD.fromJson(dynamic json) {
    label = json['label'];
    value = json['value'];
  }
  String? label;
  num? value;
CategoryD copyWith({  String? label,
  num? value,
}) => CategoryD(  label: label ?? this.label,
  value: value ?? this.value,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['label'] = label;
    map['value'] = value;
    return map;
  }

}

class CategoryC {
  CategoryC({
      this.label, 
      this.value,});

  CategoryC.fromJson(dynamic json) {
    label = json['label'];
    value = json['value'];
  }
  String? label;
  num? value;
CategoryC copyWith({  String? label,
  num? value,
}) => CategoryC(  label: label ?? this.label,
  value: value ?? this.value,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['label'] = label;
    map['value'] = value;
    return map;
  }

}

class CategoryB {
  CategoryB({
      this.label, 
      this.value,});

  CategoryB.fromJson(dynamic json) {
    label = json['label'];
    value = json['value'];
  }
  String? label;
  num? value;
CategoryB copyWith({  String? label,
  num? value,
}) => CategoryB(  label: label ?? this.label,
  value: value ?? this.value,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['label'] = label;
    map['value'] = value;
    return map;
  }

}

class CategoryA {
  CategoryA({
      this.label, 
      this.value,});

  CategoryA.fromJson(dynamic json) {
    label = json['label'];
    value = json['value'];
  }
  String? label;
  num? value;
CategoryA copyWith({  String? label,
  num? value,
}) => CategoryA(  label: label ?? this.label,
  value: value ?? this.value,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['label'] = label;
    map['value'] = value;
    return map;
  }

}

class PiVsLc {
  PiVsLc({
      this.label, 
      this.value,});

  PiVsLc.fromJson(dynamic json) {
    label = json['label'];
    value = json['value'];
  }
  String? label;
  num? value;
PiVsLc copyWith({  String? label,
  num? value,
}) => PiVsLc(  label: label ?? this.label,
  value: value ?? this.value,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['label'] = label;
    map['value'] = value;
    return map;
  }

}

class OrderVsDelivery {
  OrderVsDelivery({
      this.label, 
      this.value,});

  OrderVsDelivery.fromJson(dynamic json) {
    label = json['label'];
    value = json['value'];
  }
  String? label;
  num? value;
OrderVsDelivery copyWith({  String? label,
  num? value,
}) => OrderVsDelivery(  label: label ?? this.label,
  value: value ?? this.value,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['label'] = label;
    map['value'] = value;
    return map;
  }

}

class OrderVsInvoice {
  OrderVsInvoice({
      this.label, 
      this.value,});

  OrderVsInvoice.fromJson(dynamic json) {
    label = json['label'];
    value = json['value'];
  }
  String? label;
  num? value;
OrderVsInvoice copyWith({  String? label,
  num? value,
}) => OrderVsInvoice(  label: label ?? this.label,
  value: value ?? this.value,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['label'] = label;
    map['value'] = value;
    return map;
  }

}

class PersonWiseSales {
  PersonWiseSales({
      this.salesPerson, 
      this.htl, 
      this.pfl, 
      this.tag, 
      this.woven,});

  PersonWiseSales.fromJson(dynamic json) {
    salesPerson = json['SalesPerson'];
    htl = json['HTL'];
    pfl = json['PFL'];
    tag = json['TAG'];
    woven = json['WOVEN'];
  }
  String? salesPerson;
  num? htl;
  num? pfl;
  num? tag;
  num? woven;
PersonWiseSales copyWith({  String? salesPerson,
  num? htl,
  num? pfl,
  num? tag,
  num? woven,
}) => PersonWiseSales(  salesPerson: salesPerson ?? this.salesPerson,
  htl: htl ?? this.htl,
  pfl: pfl ?? this.pfl,
  tag: tag ?? this.tag,
  woven: woven ?? this.woven,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['SalesPerson'] = salesPerson;
    map['HTL'] = htl;
    map['PFL'] = pfl;
    map['TAG'] = tag;
    map['WOVEN'] = woven;
    return map;
  }

}

class DailySales {
  DailySales({
      this.salesDate, 
      this.salesQty, 
      this.salesValue,});

  DailySales.fromJson(dynamic json) {
    salesDate = json['SalesDate'];
    salesQty = json['SalesQty'];
    salesValue = json['SalesValue'];
  }
  String? salesDate;
  num? salesQty;
  num? salesValue;
DailySales copyWith({  String? salesDate,
  num? salesQty,
  num? salesValue,
}) => DailySales(  salesDate: salesDate ?? this.salesDate,
  salesQty: salesQty ?? this.salesQty,
  salesValue: salesValue ?? this.salesValue,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['SalesDate'] = salesDate;
    map['SalesQty'] = salesQty;
    map['SalesValue'] = salesValue;
    return map;
  }

}

class MonthlySales {
  MonthlySales({
      this.orderYrMn, 
      this.orderQuantity, 
      this.orderValue, 
      this.deliveredQuantity, 
      this.deliveredValue,});

  MonthlySales.fromJson(dynamic json) {
    orderYrMn = json['OrderYrMn'];
    orderQuantity = json['OrderQuantity'];
    orderValue = json['OrderValue'];
    deliveredQuantity = json['DeliveredQuantity'];
    deliveredValue = json['DeliveredValue'];
  }
  String? orderYrMn;
  num? orderQuantity;
  num? orderValue;
  num? deliveredQuantity;
  num? deliveredValue;
MonthlySales copyWith({  String? orderYrMn,
  num? orderQuantity,
  num? orderValue,
  num? deliveredQuantity,
  num? deliveredValue,
}) => MonthlySales(  orderYrMn: orderYrMn ?? this.orderYrMn,
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