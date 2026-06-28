import 'package:equatable/equatable.dart';

class StockPurchase extends Equatable {
  final int id;
  final int productId;
  final int qtyUnits;
  final double costPerUnit;
  final String purchaseDate;
  final String? notes;
  final String createdAt;

  const StockPurchase({
    required this.id,
    required this.productId,
    required this.qtyUnits,
    required this.costPerUnit,
    required this.purchaseDate,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        qtyUnits,
        costPerUnit,
        purchaseDate,
        notes,
        createdAt,
      ];
}
