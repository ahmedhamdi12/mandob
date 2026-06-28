import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_tables.dart';
import '../models/stock_purchase_model.dart';
import '../models/stock_movement_model.dart';

class StockLocalDataSource {
  final DatabaseHelper dbHelper;

  StockLocalDataSource({required this.dbHelper});

  Future<int> addStockPurchase(StockPurchaseModel purchase) async {
    final db = await dbHelper.database;
    
    return await db.transaction((txn) async {
      // 1. Get current product info for WAC calculation
      final List<Map<String, dynamic>> productResult = await txn.query(
        DatabaseTables.products,
        columns: ['stock_qty', 'average_cost'],
        where: 'id = ?',
        whereArgs: [purchase.productId],
      );

      if (productResult.isEmpty) {
        throw Exception('Product not found');
      }

      final currentQty = productResult.first['stock_qty'] as int;
      final currentAvgCost = (productResult.first['average_cost'] as num).toDouble();

      // 2. Calculate new WAC
      final newQty = purchase.qtyUnits;
      final newCost = purchase.costPerUnit;
      
      final totalCurrentValue = currentQty * currentAvgCost;
      final totalNewValue = newQty * newCost;
      final totalQty = currentQty + newQty;

      double newWac = currentAvgCost;
      if (totalQty > 0) {
        newWac = (totalCurrentValue + totalNewValue) / totalQty;
      }

      // 3. Insert Purchase Record
      final purchaseMap = purchase.toMap();
      purchaseMap['remaining_qty'] = purchase.qtyUnits; // Initialize for FIFO
      
      final purchaseId = await txn.insert(
        DatabaseTables.stockPurchases,
        purchaseMap,
      );

      // 4. Insert Movement Record
      final movement = StockMovementModel(
        id: 0,
        productId: purchase.productId,
        type: 'purchase',
        qty: purchase.qtyUnits,
        referenceId: purchaseId,
        createdAt: purchase.createdAt,
      );
      
      await txn.insert(
        DatabaseTables.stockMovements,
        movement.toMap(),
      );

      // 5. Update Product Stock and WAC
      await txn.update(
        DatabaseTables.products,
        {
          'stock_qty': totalQty,
          'average_cost': newWac,
        },
        where: 'id = ?',
        whereArgs: [purchase.productId],
      );

      return purchaseId;
    });
  }

  Future<List<StockMovementModel>> getStockMovements(int productId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.stockMovements,
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );

    return maps.map((e) => StockMovementModel.fromMap(e)).toList();
  }

  Future<List<StockPurchaseModel>> getProductPurchaseHistory(int productId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseTables.stockPurchases,
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'purchase_date DESC, id DESC',
    );

    return maps.map((e) => StockPurchaseModel.fromMap(e)).toList();
  }
}
