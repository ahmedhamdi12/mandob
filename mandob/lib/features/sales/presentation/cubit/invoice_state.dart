import 'package:equatable/equatable.dart';
import '../../domain/entities/invoice.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoicesLoaded extends InvoiceState {
  final List<Invoice> invoices;

  const InvoicesLoaded(this.invoices);

  @override
  List<Object> get props => [invoices];
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object> get props => [message];
}

class InvoiceOperationSuccess extends InvoiceState {
  final String message;

  const InvoiceOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
