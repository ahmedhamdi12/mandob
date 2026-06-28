import '../../domain/entities/product_unit.dart';

class ProductUnitModel extends ProductUnit {
  const ProductUnitModel({
    required super.id,
    required super.productId,
    required super.unitName,
    super.conversionFactor,
  });

  factory ProductUnitModel.fromMap(Map<String, dynamic> map) {
    return ProductUnitModel(
      id: map['id'] as int,
      productId: map['product_id'] as int,
      unitName: map['unit_name'] as String,
      conversionFactor: map['conversion_factor'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'product_id': productId,
      'unit_name': unitName,
      'conversion_factor': conversionFactor,
    };
  }

  factory ProductUnitModel.fromEntity(ProductUnit entity) {
    return ProductUnitModel(
      id: entity.id,
      productId: entity.productId,
      unitName: entity.unitName,
      conversionFactor: entity.conversionFactor,
    );
  }
}
