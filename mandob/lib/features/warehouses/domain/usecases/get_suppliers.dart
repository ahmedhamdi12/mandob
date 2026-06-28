import '../entities/supplier.dart';
import '../repositories/warehouse_repository.dart';

class GetSuppliers {
  final WarehouseRepository repository;

  GetSuppliers(this.repository);

  Future<List<Supplier>> call({String? query}) {
    return repository.getSuppliers(query: query);
  }
}
