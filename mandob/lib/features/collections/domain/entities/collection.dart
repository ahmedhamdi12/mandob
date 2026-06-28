import 'package:equatable/equatable.dart';

class Collection extends Equatable {
  final int id;
  final int customerId;
  final int? invoiceId;
  final double amount;
  final String collectDate;
  final String? notes;
  final String createdAt;

  // Joined fields for display
  final String? customerName;
  final String? invoiceNumber;

  const Collection({
    required this.id,
    required this.customerId,
    this.invoiceId,
    required this.amount,
    required this.collectDate,
    this.notes,
    required this.createdAt,
    this.customerName,
    this.invoiceNumber,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        invoiceId,
        amount,
        collectDate,
        notes,
        createdAt,
      ];
}
