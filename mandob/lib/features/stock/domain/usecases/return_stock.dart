import '../repositories/stock_repository.dart';

class ReturnStock {
  final StockRepository repository;

  ReturnStock(this.repository);

  Future<void> call(int productId, int qty) {
    return repository.returnStock(productId, qty);
  }
}
