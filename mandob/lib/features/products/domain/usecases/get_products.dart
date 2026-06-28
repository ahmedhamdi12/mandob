import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<List<Product>> call({String query = ''}) {
    return repository.getProducts(query: query);
  }
}
