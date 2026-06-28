import '../../domain/entities/collection.dart';

class CollectionModel extends Collection {
  const CollectionModel({
    required super.id,
    required super.customerId,
    super.invoiceId,
    required super.amount,
    required super.collectDate,
    super.notes,
    required super.createdAt,
    super.customerName,
    super.invoiceNumber,
  });

  factory CollectionModel.fromMap(Map<String, dynamic> map) {
    return CollectionModel(
      id: map['id'] as int,
      customerId: map['customer_id'] as int,
      invoiceId: map['invoice_id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      collectDate: map['collect_date'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
      customerName: map['customer_name'] as String?,
      invoiceNumber: map['invoice_number'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'customer_id': customerId,
      'invoice_id': invoiceId,
      'amount': amount,
      'collect_date': collectDate,
      'notes': notes,
      if (id <= 0) 'created_at': createdAt,
    };
  }

  factory CollectionModel.fromEntity(Collection entity) {
    return CollectionModel(
      id: entity.id,
      customerId: entity.customerId,
      invoiceId: entity.invoiceId,
      amount: entity.amount,
      collectDate: entity.collectDate,
      notes: entity.notes,
      createdAt: entity.createdAt,
      customerName: entity.customerName,
      invoiceNumber: entity.invoiceNumber,
    );
  }
}
