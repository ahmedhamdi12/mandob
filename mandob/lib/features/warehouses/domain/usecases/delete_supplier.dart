import '../repositories/warehouse_repository.dart';

class DeleteSupplier {
  final WarehouseRepository repository;

  DeleteSupplier(this.repository);

  Future<void> call(int id) {
    return repository.deleteSupplier(id);
  }
}
