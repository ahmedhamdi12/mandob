import '../../domain/entities/product.dart';
import '../../domain/entities/product_unit.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';
import '../models/product_unit_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Product>> getProducts({String query = ''}) async {
    return await localDataSource.getProducts(query: query);
  }

  @override
  Future<Product?> getProductById(int id) async {
    return await localDataSource.getProductById(id);
  }

  @override
  Future<List<ProductUnit>> getProductUnits(int productId) async {
    return await localDataSource.getProductUnits(productId);
  }

  @override
  Future<int> addProduct(Product product, List<ProductUnit> units) async {
    final productModel = ProductModel.fromEntity(product);
    final unitModels = units.map((u) => ProductUnitModel.fromEntity(u)).toList();
    return await localDataSource.addProduct(productModel, unitModels);
  }

  @override
  Future<int> updateProduct(Product product, List<ProductUnit> units) async {
    final productModel = ProductModel.fromEntity(product);
    final unitModels = units.map((u) => ProductUnitModel.fromEntity(u)).toList();
    return await localDataSource.updateProduct(productModel, unitModels);
  }

  @override
  Future<int> deleteProduct(int id) async {
    return await localDataSource.deleteProduct(id);
  }
}
