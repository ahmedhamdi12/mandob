import '../../domain/entities/supplier_invoice.dart';

class SupplierInvoiceModel extends SupplierInvoice {
  const SupplierInvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.supplierId,
    super.supplierName,
    required super.type,
    required super.invoiceDate,
    required super.totalAmount,
    required super.paidAmount,
    required super.remaining,
    required super.status,
    super.notes,
    required super.createdAt,
  });

  factory SupplierInvoiceModel.fromMap(Map<String, dynamic> map) {
    return SupplierInvoiceModel(
      id: map['id'] as int,
      invoiceNumber: map['invoice_number'] as String,
      supplierId: map['supplier_id'] as int,
      supplierName: map['supplier_name'] as String?,
      type: map['type'] as String? ?? 'purchase',
      invoiceDate: map['invoice_date'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num).toDouble(),
      remaining: (map['remaining'] as num).toDouble(),
      status: map['status'] as String? ?? 'active',
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'invoice_number': invoiceNumber,
      'supplier_id': supplierId,
      'type': type,
      'invoice_date': invoiceDate,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining': remaining,
      'status': status,
      'notes': notes,
      if (id <= 0) 'created_at': createdAt,
    };
  }

  factory SupplierInvoiceModel.fromEntity(SupplierInvoice entity) {
    return SupplierInvoiceModel(
      id: entity.id,
      invoiceNumber: entity.invoiceNumber,
      supplierId: entity.supplierId,
      supplierName: entity.supplierName,
      type: entity.type,
      invoiceDate: entity.invoiceDate,
      totalAmount: entity.totalAmount,
      paidAmount: entity.paidAmount,
      remaining: entity.remaining,
      status: entity.status,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }
}
