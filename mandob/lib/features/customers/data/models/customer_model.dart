import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.name,
    super.phone,
    super.address,
    super.currentBalance,
    required super.createdAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as int,
      name: map['name'] as String,
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      currentBalance: (map['current_balance'] as num?)?.toDouble() ?? 0.0,
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
      if (id <= 0) 'created_at': createdAt,
    };
  }

  factory CustomerModel.fromEntity(Customer entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      currentBalance: entity.currentBalance,
      createdAt: entity.createdAt,
    );
  }
}
