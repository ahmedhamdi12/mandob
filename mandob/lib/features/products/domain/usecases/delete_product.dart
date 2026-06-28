import '../repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<int> call(int id) {
    return repository.deleteProduct(id);
  }
}
