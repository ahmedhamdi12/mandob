import '../../domain/entities/stock_purchase.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_local_datasource.dart';
import '../models/stock_purchase_model.dart';

class StockRepositoryImpl implements StockRepository {
  final StockLocalDataSource localDataSource;

  StockRepositoryImpl({required this.localDataSource});

  @override
  Future<int> addStockPurchase(StockPurchase purchase) async {
    final purchaseModel = StockPurchaseModel.fromEntity(purchase);
    return await localDataSource.addStockPurchase(purchaseModel);
  }

  @override
  Future<List<StockMovement>> getStockMovements(int productId) async {
    return await localDataSource.getStockMovements(productId);
  }

  @override
  Future<void> returnStock(int productId, int qty) async {
    await localDataSource.returnStock(productId, qty);
  }
}
