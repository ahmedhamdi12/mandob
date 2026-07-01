import '../../domain/entities/supplier_invoice_item.dart';

class SupplierInvoiceItemModel extends SupplierInvoiceItem {
  const SupplierInvoiceItemModel({
    required super.id,
    required super.invoiceId,
    required super.itemName,
    super.productId,
    super.unitId,
    super.qtyUnits = 0,
    required super.qty,
    required super.unitPrice,
    required super.lineTotal,
  });

  factory SupplierInvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return SupplierInvoiceItemModel(
      id: map['id'] as int,
      invoiceId: map['invoice_id'] as int,
      itemName: map['item_name'] as String,
      productId: map['product_id'] as int?,
      unitId: map['unit_id'] as int?,
      qtyUnits: map['qty_units'] as int? ?? 0,
      qty: (map['qty'] as num).toDouble(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      lineTotal: (map['line_total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'invoice_id': invoiceId,
      'product_id': productId,
      'unit_id': unitId,
      'qty_units': qtyUnits,
      'item_name': itemName,
      'qty': qty,
      'unit_price': unitPrice,
      'line_total': lineTotal,
    };
  }

  factory SupplierInvoiceItemModel.fromEntity(SupplierInvoiceItem entity) {
    return SupplierInvoiceItemModel(
      id: entity.id,
      invoiceId: entity.invoiceId,
      itemName: entity.itemName,
      productId: entity.productId,
      unitId: entity.unitId,
      qtyUnits: entity.qtyUnits,
      qty: entity.qty,
      unitPrice: entity.unitPrice,
      lineTotal: entity.lineTotal,
    );
  }
}
