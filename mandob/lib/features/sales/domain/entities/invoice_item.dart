import 'package:equatable/equatable.dart';

class InvoiceItem extends Equatable {
  final int id;
  final int invoiceId;
  final int productId;
  final String? productName;
  final int qtyUnits;
  final int? unitId;
  final String? unitName;
  final double? displayQty;
  final double unitPrice;
  final double costAtSale;
  final double lineTotal;

  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    this.productName,
    required this.qtyUnits,
    this.unitId,
    this.unitName,
    this.displayQty,
    required this.unitPrice,
    required this.costAtSale,
    required this.lineTotal,
  });

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        productId,
        productName,
        qtyUnits,
        unitId,
        unitName,
        displayQty,
        unitPrice,
        costAtSale,
        lineTotal,
      ];
}
