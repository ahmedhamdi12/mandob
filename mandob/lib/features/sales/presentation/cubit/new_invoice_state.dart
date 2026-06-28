import 'package:equatable/equatable.dart';
import '../../domain/entities/invoice_item.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../products/domain/entities/product.dart';

abstract class NewInvoiceState extends Equatable {
  const NewInvoiceState();

  @override
  List<Object?> get props => [];
}

class NewInvoiceInitial extends NewInvoiceState {}

class NewInvoiceUpdating extends NewInvoiceState {}

class NewInvoiceUpdated extends NewInvoiceState {
  final Customer? selectedCustomer;
  final List<InvoiceItem> items;
  final Map<int, Product> productsCache; // To show product names
  final double totalAmount;
  final String paymentType; // 'cash' or 'credit'

  const NewInvoiceUpdated({
    this.selectedCustomer,
    required this.items,
    required this.productsCache,
    required this.totalAmount,
    this.paymentType = 'cash',
  });

  @override
  List<Object?> get props => [
        selectedCustomer,
        items,
        productsCache,
        totalAmount,
        paymentType,
      ];
}

class NewInvoiceSaving extends NewInvoiceState {}

class NewInvoiceSuccess extends NewInvoiceState {
  final String message;

  const NewInvoiceSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class NewInvoiceError extends NewInvoiceState {
  final String message;

  const NewInvoiceError(this.message);

  @override
  List<Object> get props => [message];
}
