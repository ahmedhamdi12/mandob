import '../../domain/entities/stock_movement.dart';

class StockMovementModel extends StockMovement {
  const StockMovementModel({
    required super.id,
    required super.productId,
    required super.type,
    required super.qty,
    super.referenceId,
    required super.createdAt,
  });

  factory StockMovementModel.fromMap(Map<String, dynamic> map) {
    return StockMovementModel(
      id: map['id'] as int,
      productId: map['product_id'] as int,
      type: map['type'] as String,
      qty: map['qty'] as int,
      referenceId: map['reference_id'] as int?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'product_id': productId,
      'type': type,
      'qty': qty,
      'reference_id': referenceId,
      if (id <= 0) 'created_at': createdAt,
    };
  }

  factory StockMovementModel.fromEntity(StockMovement entity) {
    return StockMovementModel(
      id: entity.id,
      productId: entity.productId,
      type: entity.type,
      qty: entity.qty,
      referenceId: entity.referenceId,
      createdAt: entity.createdAt,
    );
  }
}
