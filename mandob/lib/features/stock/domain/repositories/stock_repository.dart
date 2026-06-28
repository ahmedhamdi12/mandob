import '../entities/stock_purchase.dart';
import '../entities/stock_movement.dart';

abstract class StockRepository {
  Future<int> addStockPurchase(StockPurchase purchase);
  Future<List<StockMovement>> getStockMovements(int productId);
}
