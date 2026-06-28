import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String baseUnit;
  final int lowStockThreshold;
  final int stockQty;
  final double averageCost;
  final bool isDeleted;
  final String createdAt;
  final double? lastPurchasePrice;

  const Product({
    required this.id,
    required this.name,
    this.baseUnit = 'قطعة',
    this.lowStockThreshold = 10,
    this.stockQty = 0,
    this.averageCost = 0.0,
    this.isDeleted = false,
    required this.createdAt,
    this.lastPurchasePrice,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        baseUnit,
        lowStockThreshold,
        stockQty,
        averageCost,
        isDeleted,
        createdAt,
        lastPurchasePrice,
      ];
}
