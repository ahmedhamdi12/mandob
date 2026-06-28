import '../entities/supplier_invoice.dart';
import '../entities/supplier_invoice_item.dart';
import '../repositories/warehouse_repository.dart';

class CreateSupplierInvoice {
  final WarehouseRepository repository;

  CreateSupplierInvoice(this.repository);

  Future<int> call(SupplierInvoice invoice, List<SupplierInvoiceItem> items) {
    return repository.createSupplierInvoice(invoice, items);
  }
}
