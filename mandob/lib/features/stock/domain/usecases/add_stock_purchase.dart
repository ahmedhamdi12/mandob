import '../entities/stock_purchase.dart';
import '../repositories/stock_repository.dart';

class AddStockPurchase {
  final StockRepository repository;

  AddStockPurchase(this.repository);

  Future<int> call(StockPurchase purchase) {
    return repository.addStockPurchase(purchase);
  }
}
