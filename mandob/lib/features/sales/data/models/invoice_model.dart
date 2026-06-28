import '../../domain/entities/invoice.dart';

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.customerId,
    super.customerName,
    super.customerPhone,
    required super.invoiceDate,
    required super.totalAmount,
    required super.paidAmount,
    required super.remaining,
    required super.paymentType,
    required super.status,
    super.notes,
    required super.createdAt,
  });

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] as int,
      invoiceNumber: map['invoice_number'] as String,
      customerId: map['customer_id'] as int,
      customerName: map['customer_name'] as String?,
      customerPhone: map['customer_phone'] as String?,
      invoiceDate: map['invoice_date'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num).toDouble(),
      remaining: (map['remaining'] as num).toDouble(),
      paymentType: map['payment_type'] as String? ?? 'cash',
      status: map['status'] as String? ?? 'active',
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'invoice_date': invoiceDate,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining': remaining,
      'payment_type': paymentType,
      'status': status,
      'notes': notes,
      if (id <= 0) 'created_at': createdAt,
    };
  }

  factory InvoiceModel.fromEntity(Invoice entity) {
    return InvoiceModel(
      id: entity.id,
      invoiceNumber: entity.invoiceNumber,
      customerId: entity.customerId,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      invoiceDate: entity.invoiceDate,
      totalAmount: entity.totalAmount,
      paidAmount: entity.paidAmount,
      remaining: entity.remaining,
      paymentType: entity.paymentType,
      status: entity.status,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }
}
