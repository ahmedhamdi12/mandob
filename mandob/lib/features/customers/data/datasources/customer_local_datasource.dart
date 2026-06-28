import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_tables.dart';
import '../models/customer_model.dart';

class CustomerLocalDataSource {
  final DatabaseHelper dbHelper;

  CustomerLocalDataSource({required this.dbHelper});

  Future<List<CustomerModel>> getCustomers({String query = ''}) async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> maps;
    
    if (query.isNotEmpty) {
      maps = await db.query(
        DatabaseTables.customers,
        where: 'name LIKE ? OR phone LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );
    } else {
      maps = await db.query(
        DatabaseTables.customers,
        orderBy: 'name ASC',
      );
    }

    return List.generate(maps.length, (i) => CustomerModel.fromMap(maps[i]));
  }

  Future<CustomerModel?> getCustomerById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseTables.customers,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return CustomerModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> addCustomer(CustomerModel customer) async {
    final db = await dbHelper.database;
    return await db.insert(DatabaseTables.customers, customer.toMap());
  }

  Future<int> updateCustomer(CustomerModel customer) async {
    final db = await dbHelper.database;
    return await db.update(
      DatabaseTables.customers,
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      DatabaseTables.customers,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
