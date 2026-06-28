import 'package:equatable/equatable.dart';

class SupplierPayment extends Equatable {
  final int id;
  final int supplierId;
  final double amount;
  final String paymentDate;
  final String? notes;
  final String createdAt;
  final String? supplierName; // joined field

  const SupplierPayment({
    required this.id,
    required this.supplierId,
    required this.amount,
    required this.paymentDate,
    this.notes,
    required this.createdAt,
    this.supplierName,
  });

  @override
  List<Object?> get props => [
        id,
        supplierId,
        amount,
        paymentDate,
        notes,
        createdAt,
        supplierName,
      ];
}
