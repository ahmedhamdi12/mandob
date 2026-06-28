import '../../domain/entities/stock_purchase.dart';

class StockPurchaseModel extends StockPurchase {
  const StockPurchaseModel({
    required super.id,
    required super.productId,
    required super.qtyUnits,
    required super.costPerUnit,
    required super.purchaseDate,
    super.notes,
    required super.createdAt,
  });

  factory StockPurchaseModel.fromMap(Map<String, dynamic> map) {
    return StockPurchaseModel(
      id: map['id'] as int,
      productId: map['product_id'] as int,
      qtyUnits: map['qty_units'] as int,
      costPerUnit: (map['cost_per_unit'] as num).toDouble(),
      purchaseDate: map['purchase_date'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'product_id': productId,
      'qty_units': qtyUnits,
      'cost_per_unit': costPerUnit,
      'purchase_date': purchaseDate,
      'notes': notes,
      if (id <= 0) 'created_at': createdAt,
    };
  }

  factory StockPurchaseModel.fromEntity(StockPurchase entity) {
    return StockPurchaseModel(
      id: entity.id,
      productId: entity.productId,
      qtyUnits: entity.qtyUnits,
      costPerUnit: entity.costPerUnit,
      purchaseDate: entity.purchaseDate,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }
}
