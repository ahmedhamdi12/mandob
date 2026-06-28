import '../../domain/entities/supplier_invoice_item.dart';

abstract class SupplierInvoiceState {}

class SupplierInvoiceInitial extends SupplierInvoiceState {}

class SupplierInvoiceLoading extends SupplierInvoiceState {}

class SupplierInvoiceSuccess extends SupplierInvoiceState {
  final int invoiceId;
  SupplierInvoiceSuccess(this.invoiceId);
}

class SupplierInvoiceError extends SupplierInvoiceState {
  final String message;
  SupplierInvoiceError(this.message);
}

class SupplierInvoiceItemAdded extends SupplierInvoiceState {
  final List<SupplierInvoiceItem> items;
  final double totalAmount;
  SupplierInvoiceItemAdded(this.items, this.totalAmount);
}
