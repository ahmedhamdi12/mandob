import 'package:equatable/equatable.dart';

class SupplierInvoiceItem extends Equatable {
  final int id;
  final int invoiceId;
  final String itemName;
  final double qty;
  final double unitPrice;
  final double lineTotal;

  const SupplierInvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.itemName,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        itemName,
        qty,
        unitPrice,
        lineTotal,
      ];
}
