import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_tables.dart';
import '../models/supplier_model.dart';
import '../models/supplier_invoice_model.dart';
import '../models/supplier_invoice_item_model.dart';
import '../models/supplier_payment_model.dart';

class WarehouseLocalDataSource {
  final DatabaseHelper dbHelper;

  WarehouseLocalDataSource({required this.dbHelper});

  // --- Suppliers ---

  Future<List<SupplierModel>> getSuppliers({String? query}) async {
    final db = await dbHelper.database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (query != null && query.isNotEmpty) {
      whereClause += ' AND (name LIKE ? OR phone LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%']);
    }

    final maps = await db.query(
      DatabaseTables.suppliers,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );

    return maps.map((e) => SupplierModel.fromMap(e)).toList();
  }

  Future<SupplierModel?> getSupplierById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseTables.suppliers,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SupplierModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> addSupplier(SupplierModel supplier) async {
    final db = await dbHelper.database;
    return await db.insert(DatabaseTables.suppliers, supplier.toMap());
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    final db = await dbHelper.database;
    await db.update(
      DatabaseTables.suppliers,
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<void> deleteSupplier(int id) async {
    final db = await dbHelper.database;
    
    // Check if supplier has invoices or payments before deleting
    final invoices = await db.query(DatabaseTables.supplierInvoices, where: 'supplier_id = ?', whereArgs: [id]);
    final payments = await db.query(DatabaseTables.supplierPayments, where: 'supplier_id = ?', whereArgs: [id]);
    
    if (invoices.isNotEmpty || payments.isNotEmpty) {
      throw Exception('لا يمكن حذف المورد لوجود فواتير أو مدفوعات مرتبطة به.');
    }

    await db.delete(
      DatabaseTables.suppliers,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Supplier Invoices ---

  Future<int> createSupplierInvoice(SupplierInvoiceModel invoice, List<SupplierInvoiceItemModel> items) async {
    final db = await dbHelper.database;
    
    return await db.transaction((txn) async {
      // 1. Insert invoice
      final invoiceId = await txn.insert(
        DatabaseTables.supplierInvoices,
        invoice.toMap(),
      );

      // 2. Insert items
      for (final item in items) {
        final itemMap = item.toMap();
        itemMap['invoice_id'] = invoiceId;
        await txn.insert(DatabaseTables.supplierInvoiceItems, itemMap);

        // --- Stock Update Integration ---
        if (item.productId != null) {
          final productResult = await txn.query(
            DatabaseTables.products,
            columns: ['stock_qty'],
            where: 'id = ?',
            whereArgs: [item.productId],
          );

          if (productResult.isNotEmpty) {
            final currentQty = productResult.first['stock_qty'] as int;
            final qtyChange = invoice.type == 'purchase' ? item.qtyUnits : -item.qtyUnits;
            
            if (invoice.type == 'return' && currentQty < item.qtyUnits) {
              throw Exception('الكمية المراد إرجاعها أكبر من المخزون المتاح للمنتج: ${item.itemName}');
            }

            // Update Product Stock
            await txn.update(
              DatabaseTables.products,
              {'stock_qty': currentQty + qtyChange},
              where: 'id = ?',
              whereArgs: [item.productId],
            );

            // Record Movement
            await txn.insert(
              DatabaseTables.stockMovements,
              {
                'product_id': item.productId,
                'type': invoice.type == 'purchase' ? 'supplier_purchase' : 'supplier_return',
                'qty': qtyChange,
                'reference_id': invoiceId,
                'created_at': DateTime.now().toIso8601String(),
              },
            );

            // If Purchase, insert into stock_purchases for FIFO
            if (invoice.type == 'purchase') {
              final costPerUnit = item.qtyUnits > 0 ? (item.lineTotal / item.qtyUnits) : 0.0;
              await txn.insert(
                DatabaseTables.stockPurchases,
                {
                  'product_id': item.productId,
                  'qty_units': item.qtyUnits,
                  'cost_per_unit': costPerUnit,
                  'purchase_date': invoice.invoiceDate,
                  'remaining_qty': item.qtyUnits,
                  'created_at': DateTime.now().toIso8601String(),
                },
              );
            } else if (invoice.type == 'return') {
              // Deduct from stock_purchases (FIFO)
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
            }
          }
        }
      }

      // 3. Update supplier balance
      // If purchase, you owe them more (- remaining)
      // If return, you owe them less (+ remaining)
      final balanceChange = invoice.type == 'purchase' ? -invoice.remaining : invoice.remaining;
      
      if (balanceChange != 0) {
        await txn.rawUpdate(
          'UPDATE ${DatabaseTables.suppliers} SET current_balance = current_balance + ? WHERE id = ?',
          [balanceChange, invoice.supplierId],
        );
      }

      return invoiceId;
    });
  }

  Future<List<SupplierInvoiceModel>> getSupplierInvoices({String? date, int? supplierId, String? query}) async {
    final db = await dbHelper.database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (date != null && date.isNotEmpty) {
      whereClause += ' AND i.invoice_date LIKE ?';
      whereArgs.add('$date%');
    }
    
    if (supplierId != null) {
      whereClause += ' AND i.supplier_id = ?';
      whereArgs.add(supplierId);
    }

    if (query != null && query.isNotEmpty) {
      whereClause += ' AND (i.invoice_number LIKE ? OR s.name LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%']);
    }

    final maps = await db.rawQuery('''
      SELECT i.*, s.name as supplier_name
      FROM ${DatabaseTables.supplierInvoices} i
      LEFT JOIN ${DatabaseTables.suppliers} s ON i.supplier_id = s.id
      WHERE $whereClause
      ORDER BY i.created_at DESC
    ''', whereArgs);

    return maps.map((e) => SupplierInvoiceModel.fromMap(e)).toList();
  }

  Future<SupplierInvoiceModel?> getSupplierInvoiceById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT i.*, s.name as supplier_name
      FROM ${DatabaseTables.supplierInvoices} i
      LEFT JOIN ${DatabaseTables.suppliers} s ON i.supplier_id = s.id
      WHERE i.id = ?
    ''', [id]);

    if (maps.isNotEmpty) {
      return SupplierInvoiceModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<SupplierInvoiceItemModel>> getSupplierInvoiceItems(int invoiceId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseTables.supplierInvoiceItems,
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );

    return maps.map((e) => SupplierInvoiceItemModel.fromMap(e)).toList();
  }

  Future<void> cancelSupplierInvoice(int invoiceId) async {
    final db = await dbHelper.database;
    bool needSync = false;
    
    await db.transaction((txn) async {
      // Check if already cancelled
      final invoiceMap = await txn.query(
        DatabaseTables.supplierInvoices,
        columns: ['status', 'remaining', 'supplier_id', 'type'],
        where: 'id = ?',
        whereArgs: [invoiceId]
      );
      
      if (invoiceMap.isEmpty) throw Exception('الفاتورة غير موجودة');
      if (invoiceMap.first['status'] == 'cancelled') return;

      final remaining = (invoiceMap.first['remaining'] as num).toDouble();
      final supplierId = invoiceMap.first['supplier_id'] as int;
      final type = invoiceMap.first['type'] as String;

      // Reverse supplier balance
      final balanceChange = type == 'purchase' ? remaining : -remaining;
      
      if (balanceChange != 0) {
        await txn.rawUpdate(
          'UPDATE ${DatabaseTables.suppliers} SET current_balance = current_balance + ? WHERE id = ?',
          [balanceChange, supplierId],
        );
      }

      // Update invoice status
      await txn.update(
        DatabaseTables.supplierInvoices,
        {'status': 'cancelled'},
        where: 'id = ?',
        whereArgs: [invoiceId]
      );

      // --- Stock Reversion Integration ---
      final items = await txn.query(
        DatabaseTables.supplierInvoiceItems,
        where: 'invoice_id = ?',
        whereArgs: [invoiceId],
      );

      for (var itemMap in items) {
        final productId = itemMap['product_id'] as int?;
        if (productId != null) {
          final qtyUnits = itemMap['qty_units'] as int;
          
          final productResult = await txn.query(
            DatabaseTables.products,
            columns: ['stock_qty'],
            where: 'id = ?',
            whereArgs: [productId],
          );

          if (productResult.isNotEmpty) {
            final currentQty = productResult.first['stock_qty'] as int;
            final qtyChange = type == 'purchase' ? -qtyUnits : qtyUnits;
            
            if (type == 'purchase' && currentQty < qtyUnits) {
               throw Exception('لا يمكن إلغاء الفاتورة لأن الكمية المشتراة تم سحب جزء منها من المخزون: ${itemMap['item_name']}');
            }

            // Update Product Stock
            await txn.update(
              DatabaseTables.products,
              {'stock_qty': currentQty + qtyChange},
              where: 'id = ?',
              whereArgs: [productId],
            );

            // Record Movement
            await txn.insert(
              DatabaseTables.stockMovements,
              {
                'product_id': productId,
                'type': type == 'purchase' ? 'supplier_purchase_cancel' : 'supplier_return_cancel',
                'qty': qtyChange,
                'reference_id': invoiceId,
                'created_at': DateTime.now().toIso8601String(),
              },
            );

            // If it's a purchase cancellation, we might have a stock_purchases record that needs to be invalidated
            // We'll run a sync at the end to fix the FIFO remaining_qty for all updated products.
            needSync = true;
          }
        }
      }
    });

    // Run FIFO sync outside the transaction to fix remaining quantities
    // (since we just run it for all products, we just call the helper method)
    if (needSync) {
      await dbHelper.syncFIFOStock();
    }
  }

  // --- Supplier Payments ---

  Future<int> addSupplierPayment(SupplierPaymentModel payment) async {
    final db = await dbHelper.database;
    
    return await db.transaction((txn) async {
      final paymentId = await txn.insert(
        DatabaseTables.supplierPayments,
        payment.toMap(),
      );

      // Increase supplier balance (you paid them, so debt decreases/balance becomes more positive)
      await txn.rawUpdate(
        'UPDATE ${DatabaseTables.suppliers} SET current_balance = current_balance + ? WHERE id = ?',
        [payment.amount, payment.supplierId],
      );

      return paymentId;
    });
  }

  Future<List<SupplierPaymentModel>> getSupplierPayments({int? supplierId, String? date}) async {
    final db = await dbHelper.database;
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (supplierId != null) {
      whereClause += ' AND p.supplier_id = ?';
      whereArgs.add(supplierId);
    }
    
    if (date != null && date.isNotEmpty) {
      whereClause += ' AND p.payment_date LIKE ?';
      whereArgs.add('$date%');
    }

    final maps = await db.rawQuery('''
      SELECT p.*, s.name as supplier_name
      FROM ${DatabaseTables.supplierPayments} p
      LEFT JOIN ${DatabaseTables.suppliers} s ON p.supplier_id = s.id
      WHERE $whereClause
      ORDER BY p.payment_date DESC, p.id DESC
    ''', whereArgs);

    return maps.map((e) => SupplierPaymentModel.fromMap(e)).toList();
  }

  // --- Statistics ---

  Future<double> getTotalSupplierDebts() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(current_balance) as total FROM ${DatabaseTables.suppliers} WHERE current_balance < 0'
    );
    
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble().abs();
    }
    return 0.0;
  }

  Future<double> getSupplierDebt(int supplierId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      DatabaseTables.suppliers,
      columns: ['current_balance'],
      where: 'id = ?',
      whereArgs: [supplierId],
    );

    if (result.isNotEmpty) {
      return (result.first['current_balance'] as num).toDouble();
    }
    return 0.0;
  }
}
