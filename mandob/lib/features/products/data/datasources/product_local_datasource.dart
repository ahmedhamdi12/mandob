import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_tables.dart';
import '../models/product_model.dart';
import '../models/product_unit_model.dart';

class ProductLocalDataSource {
  final DatabaseHelper dbHelper;

  ProductLocalDataSource({required this.dbHelper});

  Future<List<ProductModel>> getProducts({String query = ''}) async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> maps;
    
    final sql = '''
      SELECT p.*, 
        (SELECT cost_per_unit FROM ${DatabaseTables.stockPurchases} 
         WHERE product_id = p.id 
         ORDER BY purchase_date DESC, id DESC LIMIT 1) as last_purchase_price,
        (SELECT SUM(remaining_qty * cost_per_unit) FROM ${DatabaseTables.stockPurchases}
         WHERE product_id = p.id AND remaining_qty > 0) as inventory_value
      FROM ${DatabaseTables.products} p
      WHERE p.is_deleted = 0
    ''';

    if (query.isNotEmpty) {
      maps = await db.rawQuery('$sql AND p.name LIKE ? ORDER BY p.name ASC', ['%$query%']);
    } else {
      maps = await db.rawQuery('$sql ORDER BY p.name ASC');
    }

    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }

  Future<ProductModel?> getProductById(int id) async {
    final db = await dbHelper.database;
    final sql = '''
      SELECT p.*, 
        (SELECT cost_per_unit FROM ${DatabaseTables.stockPurchases} 
         WHERE product_id = p.id 
         ORDER BY purchase_date DESC, id DESC LIMIT 1) as last_purchase_price,
        (SELECT SUM(remaining_qty * cost_per_unit) FROM ${DatabaseTables.stockPurchases}
         WHERE product_id = p.id AND remaining_qty > 0) as inventory_value
      FROM ${DatabaseTables.products} p
      WHERE p.id = ? AND p.is_deleted = 0
    ''';
    final maps = await db.rawQuery(sql, [id]);

    if (maps.isNotEmpty) {
      return ProductModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ProductUnitModel>> getProductUnits(int productId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      DatabaseTables.productUnits,
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    return List.generate(maps.length, (i) => ProductUnitModel.fromMap(maps[i]));
  }

  Future<int> addProduct(ProductModel product, List<ProductUnitModel> units) async {
    final db = await dbHelper.database;
    return await db.transaction((txn) async {
      final productId = await txn.insert(DatabaseTables.products, product.toMap());
      
      for (var unit in units) {
        final unitMap = unit.toMap();
        unitMap['product_id'] = productId; // Assign the newly created product ID
        await txn.insert(DatabaseTables.productUnits, unitMap);
      }
      
      return productId;
    });
  }

  Future<int> updateProduct(ProductModel product, List<ProductUnitModel> units) async {
    final db = await dbHelper.database;
    return await db.transaction((txn) async {
      await txn.update(
        DatabaseTables.products,
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );

      // Delete existing units
      await txn.delete(
        DatabaseTables.productUnits,
        where: 'product_id = ?',
        whereArgs: [product.id],
      );

      // Insert new units
      for (var unit in units) {
        final unitMap = unit.toMap();
        unitMap.remove('id'); // Ensure it inserts as new
        unitMap['product_id'] = product.id;
        await txn.insert(DatabaseTables.productUnits, unitMap);
      }

      return product.id;
    });
  }

  Future<int> deleteProduct(int id) async {
    final db = await dbHelper.database;
    return await db.update(
      DatabaseTables.products,
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
