import '../../domain/entities/supplier.dart';

class SupplierModel extends Supplier {
  const SupplierModel({
    required super.id,
    required super.name,
    super.phone,
    super.address,
    super.currentBalance,
    super.notes,
    required super.createdAt,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] as int,
      name: map['name'] as String,
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      currentBalance: (map['current_balance'] as num).toDouble(),
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'current_balance': currentBalance,
      'notes': notes,
      if (id <= 0) 'created_at': createdAt,
    };
  }

  factory SupplierModel.fromEntity(Supplier entity) {
    return SupplierModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      currentBalance: entity.currentBalance,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }
}
