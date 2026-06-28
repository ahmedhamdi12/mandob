import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_unit.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final GetProducts getProductsUseCase;
  final AddProduct addProductUseCase;
  final UpdateProduct updateProductUseCase;
  final DeleteProduct deleteProductUseCase;

  ProductCubit({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  }) : super(ProductInitial());

  Future<void> loadProducts({String query = ''}) async {
    emit(ProductLoading());
    try {
      final products = await getProductsUseCase(query: query);
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> addProduct(Product product, List<ProductUnit> units) async {
    emit(ProductLoading());
    try {
      await addProductUseCase(product, units);
      emit(const ProductOperationSuccess('تم إضافة المنتج بنجاح'));
      loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
      loadProducts(); // Reload to show list again
    }
  }

  Future<void> updateProduct(Product product, List<ProductUnit> units) async {
    emit(ProductLoading());
    try {
      await updateProductUseCase(product, units);
      emit(const ProductOperationSuccess('تم تعديل المنتج بنجاح'));
      loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
      loadProducts();
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await deleteProductUseCase(id);
      emit(const ProductOperationSuccess('تم حذف المنتج بنجاح'));
      loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
      loadProducts();
    }
  }
}
