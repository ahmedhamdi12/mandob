import '../../domain/entities/supplier_payment.dart';

class SupplierPaymentModel extends SupplierPayment {
  const SupplierPaymentModel({
    required super.id,
    required super.supplierId,
    required super.amount,
    required super.paymentDate,
    super.notes,
    required super.createdAt,
    super.supplierName,
  });

  factory SupplierPaymentModel.fromMap(Map<String, dynamic> map) {
    return SupplierPaymentModel(
      id: map['id'] as int,
      supplierId: map['supplier_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      paymentDate: map['payment_date'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
      supplierName: map['supplier_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'supplier_id': supplierId,
      'amount': amount,
      'payment_date': paymentDate,
      'notes': notes,
      if (id <= 0) 'created_at': createdAt,
    };
  }

  factory SupplierPaymentModel.fromEntity(SupplierPayment entity) {
    return SupplierPaymentModel(
      id: entity.id,
      supplierId: entity.supplierId,
      amount: entity.amount,
      paymentDate: entity.paymentDate,
      notes: entity.notes,
      createdAt: entity.createdAt,
      supplierName: entity.supplierName,
    );
  }
}
