import '../entities/supplier_invoice.dart';
import '../repositories/warehouse_repository.dart';

class GetSupplierInvoices {
  final WarehouseRepository repository;

  GetSupplierInvoices(this.repository);

  Future<List<SupplierInvoice>> call({String? date, int? supplierId, String? query}) {
    return repository.getSupplierInvoices(date: date, supplierId: supplierId, query: query);
  }
}
