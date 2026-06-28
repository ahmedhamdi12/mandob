import '../entities/supplier.dart';
import '../entities/supplier_invoice.dart';
import '../entities/supplier_invoice_item.dart';
import '../entities/supplier_payment.dart';

abstract class WarehouseRepository {
  // Suppliers
  Future<List<Supplier>> getSuppliers({String? query});
  Future<Supplier?> getSupplierById(int id);
  Future<int> addSupplier(Supplier supplier);
  Future<void> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(int id);

  // Supplier Invoices
  Future<int> createSupplierInvoice(SupplierInvoice invoice, List<SupplierInvoiceItem> items);
  Future<List<SupplierInvoice>> getSupplierInvoices({String? date, int? supplierId, String? query});
  Future<SupplierInvoice?> getSupplierInvoiceById(int id);
  Future<List<SupplierInvoiceItem>> getSupplierInvoiceItems(int invoiceId);
  Future<void> cancelSupplierInvoice(int invoiceId);

  // Supplier Payments
  Future<int> addSupplierPayment(SupplierPayment payment);
  Future<List<SupplierPayment>> getSupplierPayments({int? supplierId, String? date});

  // Statistics
  Future<double> getTotalSupplierDebts();
  Future<double> getSupplierDebt(int supplierId);
}
