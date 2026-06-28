import 'package:equatable/equatable.dart';

class SupplierInvoice extends Equatable {
  final int id;
  final String invoiceNumber;
  final int supplierId;
  final String? supplierName; // joined field
  final String type; // 'purchase' or 'return'
  final String invoiceDate;
  final double totalAmount;
  final double paidAmount;
  final double remaining;
  final String status;
  final String? notes;
  final String createdAt;

  const SupplierInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.supplierId,
    this.supplierName,
    required this.type,
    required this.invoiceDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.remaining,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        supplierId,
        supplierName,
        type,
        invoiceDate,
        totalAmount,
        paidAmount,
        remaining,
        status,
        notes,
        createdAt,
      ];
}
