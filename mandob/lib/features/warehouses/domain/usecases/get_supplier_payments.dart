import '../entities/supplier_payment.dart';
import '../repositories/warehouse_repository.dart';

class GetSupplierPayments {
  final WarehouseRepository repository;

  GetSupplierPayments(this.repository);

  Future<List<SupplierPayment>> call({int? supplierId, String? date}) {
    return repository.getSupplierPayments(supplierId: supplierId, date: date);
  }
}
