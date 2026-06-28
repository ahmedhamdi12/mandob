import '../entities/stock_movement.dart';
import '../repositories/stock_repository.dart';

class GetStockMovements {
  final StockRepository repository;

  GetStockMovements(this.repository);

  Future<List<StockMovement>> call(int productId) {
    return repository.getStockMovements(productId);
  }
}
