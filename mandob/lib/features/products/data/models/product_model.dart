import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.baseUnit,
    super.lowStockThreshold,
    super.stockQty,
    super.averageCost,
    super.isDeleted,
    required super.createdAt,
    super.lastPurchasePrice,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int,
      name: map['name'] as String,
      baseUnit: map['base_unit'] as String? ?? 'قطعة',
      lowStockThreshold: map['low_stock_threshold'] as int? ?? 10,
      stockQty: map['stock_qty'] as int? ?? 0,
      averageCost: (map['average_cost'] as num?)?.toDouble() ?? 0.0,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String,
      lastPurchasePrice: (map['last_purchase_price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'name': name,
      'base_unit': baseUnit,
      'low_stock_threshold': lowStockThreshold,
      'stock_qty': stockQty,
      'average_cost': averageCost,
      'is_deleted': isDeleted ? 1 : 0,
      if (id <= 0) 'created_at': createdAt,
    };
  }

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      baseUnit: entity.baseUnit,
      lowStockThreshold: entity.lowStockThreshold,
      stockQty: entity.stockQty,
      averageCost: entity.averageCost,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
      lastPurchasePrice: entity.lastPurchasePrice,
    );
  }
}
