import '../entities/product.dart';
import '../entities/product_unit.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<int> call(Product product, List<ProductUnit> units) {
    return repository.updateProduct(product, units);
  }
}
