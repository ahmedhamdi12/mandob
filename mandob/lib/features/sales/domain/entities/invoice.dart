import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  final int id;
  final String invoiceNumber;
  final int customerId;
  final String? customerName;
  final String? customerPhone;
  final String invoiceDate;
  final double totalAmount;
  final double paidAmount;
  final double remaining;
  final String paymentType; // cash / credit
  final String status; // active / cancelled
  final String? notes;
  final String createdAt;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    required this.invoiceDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.remaining,
    required this.paymentType,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        customerId,
        customerName,
        customerPhone,
        invoiceDate,
        totalAmount,
        paidAmount,
        remaining,
        paymentType,
        status,
        notes,
        createdAt,
      ];
}
