import '../../domain/entities/last_price.dart';

class LastPriceModel extends LastPrice {
  const LastPriceModel({
    required super.productId,
    required super.customerId,
    super.unitId,
    required super.lastPrice,
    required super.updatedAt,
  });

  factory LastPriceModel.fromMap(Map<String, dynamic> map) {
    return LastPriceModel(
      productId: map['product_id'] as int,
      customerId: map['customer_id'] as int,
      unitId: map['unit_id'] as int?,
      lastPrice: (map['last_price'] as num).toDouble(),
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'customer_id': customerId,
      'unit_id': unitId,
      'last_price': lastPrice,
      'updated_at': updatedAt,
    };
  }

  factory LastPriceModel.fromEntity(LastPrice entity) {
    return LastPriceModel(
      productId: entity.productId,
      customerId: entity.customerId,
      unitId: entity.unitId,
      lastPrice: entity.lastPrice,
      updatedAt: entity.updatedAt,
    );
  }
}
