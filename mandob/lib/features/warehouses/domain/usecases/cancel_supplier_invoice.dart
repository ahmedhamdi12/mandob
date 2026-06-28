import '../repositories/warehouse_repository.dart';

class CancelSupplierInvoice {
  final WarehouseRepository repository;

  CancelSupplierInvoice(this.repository);

  Future<void> call(int invoiceId) {
    return repository.cancelSupplierInvoice(invoiceId);
  }
}
