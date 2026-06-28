import '../entities/supplier_payment.dart';
import '../repositories/warehouse_repository.dart';

class AddSupplierPayment {
  final WarehouseRepository repository;

  AddSupplierPayment(this.repository);

  Future<int> call(SupplierPayment payment) {
    return repository.addSupplierPayment(payment);
  }
}
