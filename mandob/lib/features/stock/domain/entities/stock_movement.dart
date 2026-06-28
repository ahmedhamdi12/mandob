import 'package:equatable/equatable.dart';

class StockMovement extends Equatable {
  final int id;
  final int productId;
  final String type; // purchase / sale / cancel_invoice / manual_adjustment
  final int qty; // positive for in, negative for out
  final int? referenceId; // invoice_id or purchase_id
  final String createdAt;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.type,
    required this.qty,
    this.referenceId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        type,
        qty,
        referenceId,
        createdAt,
      ];
}
