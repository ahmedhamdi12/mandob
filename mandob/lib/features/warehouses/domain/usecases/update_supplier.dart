import '../entities/supplier.dart';
import '../repositories/warehouse_repository.dart';

class UpdateSupplier {
  final WarehouseRepository repository;

  UpdateSupplier(this.repository);

  Future<void> call(Supplier supplier) {
    return repository.updateSupplier(supplier);
  }
}
