import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_tables.dart';
import '../models/collection_model.dart';

class CollectionLocalDataSource {
  final DatabaseHelper dbHelper;

  CollectionLocalDataSource({required this.dbHelper});

  /// Adds a collection and updates the related invoice's paid_amount and remaining.
  /// Uses a transaction to ensure atomicity.
  Future<int> addCollection(CollectionModel collection) async {
    final db = await dbHelper.database;

    return await db.transaction((txn) async {
      // 1. Insert collection record
      final collectionId = await txn.insert(
        DatabaseTables.collections,
        collection.toMap(),
      );

      // 2. If linked to an invoice, update its paid_amount and remaining
      if (collection.invoiceId != null) {
        await txn.rawUpdate('''
          UPDATE ${DatabaseTables.invoices}
          SET paid_amount = paid_amount + ?,
              remaining = remaining - ?
          WHERE id = ?
        ''', [collection.amount, collection.amount, collection.invoiceId]);
      }

      // 3. Update customer balance (Debt decreases -> balance becomes more positive)
      await txn.rawUpdate(
        'UPDATE ${DatabaseTables.customers} SET current_balance = current_balance + ? WHERE id = ?',
        [collection.amount, collection.customerId]
      );

      return collectionId;
    });
  }

  /// Get collections with optional date and customer filters.
  /// Joins customers and invoices tables for display names.
  Future<List<CollectionModel>> getCollections({String? date, int? customerId}) async {
    final db = await dbHelper.database;

    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (date != null && date.isNotEmpty) {
      whereClause += ' AND c.collect_date LIKE ?';
      whereArgs.add('$date%');
    }

    if (customerId != null) {
      whereClause += ' AND c.customer_id = ?';
      whereArgs.add(customerId);
    }

    final maps = await db.rawQuery('''
      SELECT c.*, 
             cu.name as customer_name,
             i.invoice_number as invoice_number
      FROM ${DatabaseTables.collections} c
      LEFT JOIN ${DatabaseTables.customers} cu ON c.customer_id = cu.id
      LEFT JOIN ${DatabaseTables.invoices} i ON c.invoice_id = i.id
      WHERE $whereClause
      ORDER BY c.collect_date DESC
    ''', whereArgs);

    return maps.map((e) => CollectionModel.fromMap(e)).toList();
  }

  /// Get collections linked to a specific invoice.
  Future<List<CollectionModel>> getCollectionsByInvoice(int invoiceId) async {
    final db = await dbHelper.database;

    final maps = await db.rawQuery('''
      SELECT c.*, 
             cu.name as customer_name,
             i.invoice_number as invoice_number
      FROM ${DatabaseTables.collections} c
      LEFT JOIN ${DatabaseTables.customers} cu ON c.customer_id = cu.id
      LEFT JOIN ${DatabaseTables.invoices} i ON c.invoice_id = i.id
      WHERE c.invoice_id = ?
      ORDER BY c.collect_date DESC
    ''', [invoiceId]);

    return maps.map((e) => CollectionModel.fromMap(e)).toList();
  }

  /// Sum of collections for a given date (or all if null).
  Future<double> getTotalCollections({String? date}) async {
    final db = await dbHelper.database;

    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (date != null) {
      whereClause += ' AND collect_date LIKE ?';
      whereArgs.add('$date%');
    }

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM ${DatabaseTables.collections} WHERE $whereClause',
      whereArgs,
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  /// Get total outstanding debt for a specific customer.
  /// Debt = negative current_balance (the customer owes us).
  Future<double> getCustomerDebt(int customerId) async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
      SELECT current_balance
      FROM ${DatabaseTables.customers}
      WHERE id = ?
    ''', [customerId]);

    if (result.isNotEmpty && result.first['current_balance'] != null) {
      final balance = (result.first['current_balance'] as num).toDouble();
      if (balance < 0) return balance.abs(); // Return positive value representing debt
    }
    return 0.0;
  }

  /// Get total outstanding debts across ALL customers.
  Future<double> getTotalDebts() async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
      SELECT SUM(current_balance) as total
      FROM ${DatabaseTables.customers}
      WHERE current_balance < 0
    ''');

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble().abs(); // Return positive value representing debt
    }
    return 0.0;
  }
}
