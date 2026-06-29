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
      // 1. Get current product info
      final List<Map<String, dynamic>> productResult = await txn.query(
        DatabaseTables.products,
        columns: ['stock_qty'],
        where: 'id = ?',
        whereArgs: [purchase.productId],
      );

      final currentQty = productResult.first['stock_qty'] as int;

      final newQty = purchase.qtyUnits;
      final totalQty = currentQty + newQty;

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

      // 5. Update Product Stock
      await txn.update(
        DatabaseTables.products,
        {
          'stock_qty': totalQty,
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
  
  Future<void> returnStock(int productId, int qty) async {
    final db = await dbHelper.database;
    
    await db.transaction((txn) async {
      // 1. Get current product info
      final List<Map<String, dynamic>> productResult = await txn.query(
        DatabaseTables.products,
        columns: ['stock_qty'],
        where: 'id = ?',
        whereArgs: [productId],
      );

      if (productResult.isEmpty) {
        throw Exception('Product not found');
      }

      final currentQty = productResult.first['stock_qty'] as int;
      if (currentQty < qty) {
        throw Exception('الكمية المراد إرجاعها أكبر من المخزون المتاح');
      }

      // 2. Insert Movement Record
      await txn.insert(
        DatabaseTables.stockMovements,
        {
          'product_id': productId,
          'type': 'stock_return',
          'qty': -qty,
          'created_at': DateTime.now().toIso8601String(),
        }
      );

      // 3. Update Product Stock
      await txn.update(
        DatabaseTables.products,
        {
          'stock_qty': currentQty - qty,
        },
        where: 'id = ?',
        whereArgs: [productId],
      );

      // 4. Deduct from stock_purchases (FIFO)
      int qtyToDeduct = qty;
      final batches = await txn.query(
        DatabaseTables.stockPurchases,
        where: 'product_id = ? AND remaining_qty > 0',
        whereArgs: [productId],
        orderBy: 'purchase_date ASC, id ASC',
      );

      for (var batch in batches) {
        if (qtyToDeduct <= 0) break;

        final batchId = batch['id'] as int;
        final batchRemaining = batch['remaining_qty'] as int;

        if (batchRemaining >= qtyToDeduct) {
          await txn.update(
            DatabaseTables.stockPurchases,
            {'remaining_qty': batchRemaining - qtyToDeduct},
            where: 'id = ?',
            whereArgs: [batchId],
          );
          qtyToDeduct = 0;
        } else {
          qtyToDeduct -= batchRemaining;
          await txn.update(
            DatabaseTables.stockPurchases,
            {'remaining_qty': 0},
            where: 'id = ?',
            whereArgs: [batchId],
          );
        }
      }
    });
  }
}
