import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_tables.dart';
import '../models/invoice_model.dart';
import '../models/invoice_item_model.dart';
import '../models/last_price_model.dart';

class InvoiceLocalDataSource {
  final DatabaseHelper dbHelper;

  InvoiceLocalDataSource({required this.dbHelper});

  Future<int> createInvoice(InvoiceModel invoice, List<InvoiceItemModel> items) async {
    final db = await dbHelper.database;
    
    return await db.transaction((txn) async {
      // 1. Insert invoice
      final invoiceId = await txn.insert(
        DatabaseTables.invoices, 
        invoice.toMap()
      );

      for (final item in items) {
        // FIFO Calculation for cost_at_sale
        double totalCostForThisItem = 0.0;
        int qtyToDeduct = item.qtyUnits;
        
        final batches = await txn.query(
          DatabaseTables.stockPurchases,
          where: 'product_id = ? AND remaining_qty > 0',
          whereArgs: [item.productId],
          orderBy: 'purchase_date ASC, id ASC',
        );

        for (var batch in batches) {
          if (qtyToDeduct <= 0) break;

          final batchId = batch['id'] as int;
          final batchRemaining = batch['remaining_qty'] as int;
          final batchCost = (batch['cost_per_unit'] as num).toDouble();

          if (batchRemaining >= qtyToDeduct) {
            totalCostForThisItem += (qtyToDeduct * batchCost);
            await txn.update(
              DatabaseTables.stockPurchases,
              {'remaining_qty': batchRemaining - qtyToDeduct},
              where: 'id = ?',
              whereArgs: [batchId],
            );
            qtyToDeduct = 0;
          } else {
            totalCostForThisItem += (batchRemaining * batchCost);
            qtyToDeduct -= batchRemaining;
            await txn.update(
              DatabaseTables.stockPurchases,
              {'remaining_qty': 0},
              where: 'id = ?',
              whereArgs: [batchId],
            );
          }
        }

        if (qtyToDeduct > 0) {
           final productResult = await txn.query(DatabaseTables.products, columns: ['average_cost'], where: 'id = ?', whereArgs: [item.productId]);
           double avgCost = 0.0;
           if (productResult.isNotEmpty) avgCost = (productResult.first['average_cost'] as num).toDouble();
           totalCostForThisItem += (qtyToDeduct * avgCost);
        }

        double calculatedUnitCostAtSale = item.qtyUnits > 0 ? (totalCostForThisItem / item.qtyUnits) : 0.0;

        // 2. Insert invoice item
        final itemMap = item.copyWith(
          invoiceId: invoiceId, 
          costAtSale: calculatedUnitCostAtSale
        ).toMap();
        await txn.insert(DatabaseTables.invoiceItems, itemMap);

        // 3. Update product stock
        await txn.rawUpdate(
          'UPDATE ${DatabaseTables.products} SET stock_qty = stock_qty - ? WHERE id = ?',
          [item.qtyUnits, item.productId],
        );

        // 4. Insert stock movement
        await txn.insert(DatabaseTables.stockMovements, {
          'product_id': item.productId,
          'type': 'sale',
          'qty': -item.qtyUnits,
          'reference_id': invoiceId,
          'created_at': invoice.createdAt,
        });

        // 5. Update last price
        await txn.insert(
          DatabaseTables.lastPrices, 
          {
            'product_id': item.productId,
            'customer_id': invoice.customerId,
            'unit_id': item.unitId,
            'last_price': item.unitPrice,
            'updated_at': invoice.createdAt,
          }, 
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // 6. Update customer balance (Debt increases -> balance becomes more negative)
      if (invoice.remaining > 0) {
        await txn.rawUpdate(
          'UPDATE ${DatabaseTables.customers} SET current_balance = current_balance - ? WHERE id = ?',
          [invoice.remaining, invoice.customerId]
        );
      }

      return invoiceId;
    });
  }

  Future<List<InvoiceModel>> getInvoices({String? date, int? customerId, String? query}) async {
    final db = await dbHelper.database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (date != null && date.isNotEmpty) {
      whereClause += ' AND i.invoice_date LIKE ?';
      whereArgs.add('$date%');
    }
    
    if (customerId != null) {
      whereClause += ' AND i.customer_id = ?';
      whereArgs.add(customerId);
    }

    if (query != null && query.isNotEmpty) {
      whereClause += ' AND (i.invoice_number LIKE ? OR c.name LIKE ? OR c.phone LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%', '%$query%']);
    }

    final maps = await db.rawQuery('''
      SELECT i.*, c.name as customer_name, c.phone as customer_phone
      FROM ${DatabaseTables.invoices} i
      LEFT JOIN ${DatabaseTables.customers} c ON i.customer_id = c.id
      WHERE $whereClause
      ORDER BY i.created_at DESC
    ''', whereArgs);

    return maps.map((e) => InvoiceModel.fromMap(e)).toList();
  }

  Future<double> getTotalSales({String? date}) async {
    final db = await dbHelper.database;
    String whereClause = 'status != "cancelled"';
    List<dynamic> whereArgs = [];

    if (date != null && date.isNotEmpty) {
      whereClause += ' AND invoice_date LIKE ?';
      whereArgs.add('$date%');
    }

    final result = await db.rawQuery(
      'SELECT SUM(total_amount) as total FROM ${DatabaseTables.invoices} WHERE $whereClause',
      whereArgs
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<double> getTotalCollections({String? date}) async {
    final db = await dbHelper.database;
    String whereClause = 'status != "cancelled"';
    List<dynamic> whereArgs = [];

    if (date != null && date.isNotEmpty) {
      whereClause += ' AND invoice_date LIKE ?';
      whereArgs.add('$date%');
    }

    final result = await db.rawQuery(
      'SELECT SUM(paid_amount) as total FROM ${DatabaseTables.invoices} WHERE $whereClause',
      whereArgs
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<InvoiceModel?> getInvoiceById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT i.*, c.name as customer_name, c.phone as customer_phone
      FROM ${DatabaseTables.invoices} i
      LEFT JOIN ${DatabaseTables.customers} c ON i.customer_id = c.id
      WHERE i.id = ?
    ''', [id]);

    if (maps.isNotEmpty) {
      return InvoiceModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<InvoiceItemModel>> getInvoiceItems(int invoiceId) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT ii.*, 
             p.name as product_name,
             pu.unit_name as unit_name
      FROM ${DatabaseTables.invoiceItems} ii
      LEFT JOIN ${DatabaseTables.products} p ON ii.product_id = p.id
      LEFT JOIN ${DatabaseTables.productUnits} pu ON ii.unit_id = pu.id
      WHERE ii.invoice_id = ?
    ''', [invoiceId]);

    return maps.map((e) => InvoiceItemModel.fromMap(e)).toList();
  }

  Future<LastPriceModel?> getLastPrice(int productId, int customerId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseTables.lastPrices,
      where: 'product_id = ? AND customer_id = ?',
      whereArgs: [productId, customerId],
    );

    if (maps.isNotEmpty) {
      return LastPriceModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> cancelInvoice(int invoiceId) async {
    final db = await dbHelper.database;
    
    await db.transaction((txn) async {
      // Check if already cancelled
      final invoiceMap = await txn.query(
        DatabaseTables.invoices,
        columns: ['status', 'created_at', 'remaining', 'customer_id'],
        where: 'id = ?',
        whereArgs: [invoiceId]
      );
      
      if (invoiceMap.isEmpty) throw Exception('Invoice not found');
      if (invoiceMap.first['status'] == 'cancelled') return;

      final nowIso = DateTime.now().toIso8601String();
      final invoiceRemaining = (invoiceMap.first['remaining'] as num).toDouble();
      final customerId = invoiceMap.first['customer_id'] as int;

      // Get items to restore stock
      final itemsMap = await txn.query(
        DatabaseTables.invoiceItems,
        columns: ['product_id', 'qty_units', 'cost_at_sale'],
        where: 'invoice_id = ?',
        whereArgs: [invoiceId]
      );

      for (var item in itemsMap) {
        final productId = item['product_id'] as int;
        final qtyUnits = item['qty_units'] as int;
        final costAtSale = (item['cost_at_sale'] as num).toDouble();

        // Restore stock to products table
        await txn.rawUpdate(
          'UPDATE ${DatabaseTables.products} SET stock_qty = stock_qty + ? WHERE id = ?',
          [qtyUnits, productId],
        );

        // Add back to stock purchases for FIFO to work
        await txn.insert(
          DatabaseTables.stockPurchases,
          {
            'product_id': productId,
            'qty_units': qtyUnits,
            'cost_per_unit': costAtSale,
            'purchase_date': nowIso,
            'notes': 'Refund for Invoice #$invoiceId',
            'remaining_qty': qtyUnits,
            'created_at': nowIso,
          }
        );

        // Add cancellation movement
        await txn.insert(DatabaseTables.stockMovements, {
          'product_id': productId,
          'type': 'cancel_invoice',
          'qty': qtyUnits,
          'reference_id': invoiceId,
          'created_at': nowIso,
        });
      }

      // Restore customer balance (Reverse debt)
      if (invoiceRemaining > 0) {
        await txn.rawUpdate(
          'UPDATE ${DatabaseTables.customers} SET current_balance = current_balance + ? WHERE id = ?',
          [invoiceRemaining, customerId]
        );
      }

      // Update invoice status
      await txn.update(
        DatabaseTables.invoices,
        {'status': 'cancelled'},
        where: 'id = ?',
        whereArgs: [invoiceId]
      );
    });
  }
}
