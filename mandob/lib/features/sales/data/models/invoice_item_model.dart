import '../../domain/entities/invoice_item.dart';

class InvoiceItemModel extends InvoiceItem {
  const InvoiceItemModel({
    required super.id,
    required super.invoiceId,
    required super.productId,
    super.productName,
    required super.qtyUnits,
    super.unitId,
    super.unitName,
    super.displayQty,
    required super.unitPrice,
    required super.costAtSale,
    required super.lineTotal,
  });

  factory InvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return InvoiceItemModel(
      id: map['id'] as int,
      invoiceId: map['invoice_id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String?,
      qtyUnits: map['qty_units'] as int,
      unitId: map['unit_id'] as int?,
      unitName: map['unit_name'] as String?,
      displayQty: (map['display_qty'] as num?)?.toDouble(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      costAtSale: (map['cost_at_sale'] as num).toDouble(),
      lineTotal: (map['line_total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'invoice_id': invoiceId,
      'product_id': productId,
      'qty_units': qtyUnits,
      'unit_id': unitId,
      'display_qty': displayQty,
      'unit_price': unitPrice,
      'cost_at_sale': costAtSale,
      'line_total': lineTotal,
    };
  }

  factory InvoiceItemModel.fromEntity(InvoiceItem entity) {
    return InvoiceItemModel(
      id: entity.id,
      invoiceId: entity.invoiceId,
      productId: entity.productId,
      productName: entity.productName,
      qtyUnits: entity.qtyUnits,
      unitId: entity.unitId,
      unitName: entity.unitName,
      displayQty: entity.displayQty,
      unitPrice: entity.unitPrice,
      costAtSale: entity.costAtSale,
      lineTotal: entity.lineTotal,
    );
  }

  InvoiceItemModel copyWith({
    int? id,
    int? invoiceId,
    int? productId,
    String? productName,
    int? qtyUnits,
    int? unitId,
    String? unitName,
    double? displayQty,
    double? unitPrice,
    double? costAtSale,
    double? lineTotal,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      qtyUnits: qtyUnits ?? this.qtyUnits,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      displayQty: displayQty ?? this.displayQty,
      unitPrice: unitPrice ?? this.unitPrice,
      costAtSale: costAtSale ?? this.costAtSale,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }
}
