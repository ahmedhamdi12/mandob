import '../entities/product.dart';
import '../entities/product_unit.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({String query = ''});
  Future<Product?> getProductById(int id);
  Future<List<ProductUnit>> getProductUnits(int productId);
  Future<int> addProduct(Product product, List<ProductUnit> units);
  Future<int> updateProduct(Product product, List<ProductUnit> units);
  Future<int> deleteProduct(int id); // Soft delete
}
