import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_tables.dart';
import '../models/expense_model.dart';

class ExpenseLocalDataSource {
  final DatabaseHelper dbHelper;

  ExpenseLocalDataSource({required this.dbHelper});

  Future<int> addExpense(ExpenseModel expense) async {
    final db = await dbHelper.database;
    return await db.insert(DatabaseTables.expenses, expense.toMap());
  }

  Future<List<ExpenseModel>> getExpenses({String? startDate, String? endDate, String? category}) async {
    final db = await dbHelper.database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += ' AND expense_date >= ?';
      whereArgs.add(startDate);
    }
    
    if (endDate != null) {
      whereClause += ' AND expense_date <= ?';
      whereArgs.add(endDate);
    }

    if (category != null && category.isNotEmpty) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }

    final maps = await db.query(
      DatabaseTables.expenses,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'expense_date DESC',
    );

    return maps.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  Future<double> getTotalExpenses({String? date}) async {
    final db = await dbHelper.database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (date != null) {
      // Just check if it starts with the date (for daily sum) or specific date
      whereClause += ' AND expense_date LIKE ?';
      whereArgs.add('$date%');
    }

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM ${DatabaseTables.expenses} WHERE $whereClause',
      whereArgs
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    
    return 0.0;
  }
}
