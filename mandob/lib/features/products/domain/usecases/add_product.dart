import '../entities/product.dart';
import '../entities/product_unit.dart';
import '../repositories/product_repository.dart';

class AddProduct {
  final ProductRepository repository;

  AddProduct(this.repository);

  Future<int> call(Product product, List<ProductUnit> units) {
    return repository.addProduct(product, units);
  }
}
