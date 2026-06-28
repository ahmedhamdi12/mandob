import '../entities/supplier.dart';
import '../repositories/warehouse_repository.dart';

class AddSupplier {
  final WarehouseRepository repository;

  AddSupplier(this.repository);

  Future<int> call(Supplier supplier) {
    return repository.addSupplier(supplier);
  }
}
