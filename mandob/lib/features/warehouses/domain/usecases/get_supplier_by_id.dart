import '../entities/supplier.dart';
import '../repositories/warehouse_repository.dart';

class GetSupplierById {
  final WarehouseRepository repository;

  GetSupplierById(this.repository);

  Future<Supplier?> call(int id) {
    return repository.getSupplierById(id);
  }
}
