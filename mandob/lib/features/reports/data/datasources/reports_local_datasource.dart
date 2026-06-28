import '../../../../core/database/database_helper.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/entities/report_entities.dart';

class ReportsLocalDataSource {
  final DatabaseHelper dbHelper;

  ReportsLocalDataSource({required this.dbHelper});

  Future<ProfitReport> getProfitReport({String? startDate, String? endDate}) async {
    final db = await dbHelper.database;

    String whereClause = "status = 'active'";
    List<dynamic> whereArgs = [];

    if (startDate != null && startDate.isNotEmpty) {
      whereClause += " AND invoice_date >= ?";
      whereArgs.add(startDate);
    }
    if (endDate != null && endDate.isNotEmpty) {
      whereClause += " AND invoice_date <= ?";
      // append time to cover the whole end day if only date is passed
      whereArgs.add(endDate.contains('T') ? endDate : '${endDate}T23:59:59');
    }

    // Query 1: Total Sales and Total Costs from invoice_items
    final salesResult = await db.rawQuery('''
      SELECT 
        SUM(i.total_amount) as total_sales,
        SUM(ii.cost_at_sale * ii.qty_units) as total_costs
      FROM ${DatabaseTables.invoices} i
      LEFT JOIN ${DatabaseTables.invoiceItems} ii ON i.id = ii.invoice_id
      WHERE i.$whereClause
    ''', whereArgs);

    double totalSales = 0.0;
    double totalCosts = 0.0;

    if (salesResult.isNotEmpty) {
      totalSales = (salesResult.first['total_sales'] as num?)?.toDouble() ?? 0.0;
      totalCosts = (salesResult.first['total_costs'] as num?)?.toDouble() ?? 0.0;
    }

    // Since we sum total_amount joined on invoiceItems, total_amount will be duplicated if there are multiple items!
    // Let's do it better:
    // Sales: SUM(line_total) from invoice_items
    // Costs: SUM(cost_at_sale * qty_units) from invoice_items

    final correctedSalesResult = await db.rawQuery('''
      SELECT 
        SUM(ii.line_total) as total_sales,
        SUM(ii.cost_at_sale * ii.qty_units) as total_costs
      FROM ${DatabaseTables.invoices} i
      INNER JOIN ${DatabaseTables.invoiceItems} ii ON i.id = ii.invoice_id
      WHERE i.$whereClause
    ''', whereArgs);

    if (correctedSalesResult.isNotEmpty) {
      totalSales = (correctedSalesResult.first['total_sales'] as num?)?.toDouble() ?? 0.0;
      totalCosts = (correctedSalesResult.first['total_costs'] as num?)?.toDouble() ?? 0.0;
    }

    // Query 2: Expenses
    String expWhereClause = "1=1";
    List<dynamic> expWhereArgs = [];
    if (startDate != null && startDate.isNotEmpty) {
      expWhereClause += " AND expense_date >= ?";
      expWhereArgs.add(startDate);
    }
    if (endDate != null && endDate.isNotEmpty) {
      expWhereClause += " AND expense_date <= ?";
      expWhereArgs.add(endDate.contains('T') ? endDate : '${endDate}T23:59:59');
    }

    final expResult = await db.rawQuery('''
      SELECT SUM(amount) as total_expenses
      FROM ${DatabaseTables.expenses}
      WHERE $expWhereClause
    ''', expWhereArgs);

    double totalExpenses = 0.0;
    if (expResult.isNotEmpty) {
      totalExpenses = (expResult.first['total_expenses'] as num?)?.toDouble() ?? 0.0;
    }

    // Total Costs = Cost of goods sold + Expenses
    double totalCostsWithExpenses = totalCosts + totalExpenses;
    double netProfit = totalSales - totalCostsWithExpenses;

    return ProfitReport(
      totalSales: totalSales,
      totalCosts: totalCostsWithExpenses,
      netProfit: netProfit,
    );
  }

  Future<List<ProductSalesReport>> getTopSellingProducts({String? startDate, String? endDate, int limit = 10}) async {
    final db = await dbHelper.database;

    String whereClause = "i.status = 'active'";
    List<dynamic> whereArgs = [];

    if (startDate != null && startDate.isNotEmpty) {
      whereClause += " AND i.invoice_date >= ?";
      whereArgs.add(startDate);
    }
    if (endDate != null && endDate.isNotEmpty) {
      whereClause += " AND i.invoice_date <= ?";
      whereArgs.add(endDate.contains('T') ? endDate : '${endDate}T23:59:59');
    }

    final result = await db.rawQuery('''
      SELECT 
        ii.product_id,
        p.name as product_name,
        SUM(ii.qty_units) as total_qty,
        SUM(ii.line_total) as total_revenue
      FROM ${DatabaseTables.invoiceItems} ii
      INNER JOIN ${DatabaseTables.invoices} i ON ii.invoice_id = i.id
      INNER JOIN ${DatabaseTables.products} p ON ii.product_id = p.id
      WHERE $whereClause
      GROUP BY ii.product_id, p.name
      ORDER BY total_qty DESC
      LIMIT ?
    ''', [...whereArgs, limit]);

    return result.map((e) => ProductSalesReport(
      productId: e['product_id'] as int,
      productName: e['product_name'] as String,
      totalQtySold: (e['total_qty'] as num).toDouble(),
      totalRevenue: (e['total_revenue'] as num).toDouble(),
    )).toList();
  }

  Future<List<CustomerSalesReport>> getTopCustomers({String? startDate, String? endDate, int limit = 10}) async {
    final db = await dbHelper.database;

    String whereClause = "status = 'active'";
    List<dynamic> whereArgs = [];

    if (startDate != null && startDate.isNotEmpty) {
      whereClause += " AND invoice_date >= ?";
      whereArgs.add(startDate);
    }
    if (endDate != null && endDate.isNotEmpty) {
      whereClause += " AND invoice_date <= ?";
      whereArgs.add(endDate.contains('T') ? endDate : '${endDate}T23:59:59');
    }

    final result = await db.rawQuery('''
      SELECT 
        i.customer_id,
        c.name as customer_name,
        SUM(i.total_amount) as total_purchases
      FROM ${DatabaseTables.invoices} i
      INNER JOIN ${DatabaseTables.customers} c ON i.customer_id = c.id
      WHERE $whereClause
      GROUP BY i.customer_id, c.name
      ORDER BY total_purchases DESC
      LIMIT ?
    ''', [...whereArgs, limit]);

    return result.map((e) => CustomerSalesReport(
      customerId: e['customer_id'] as int,
      customerName: e['customer_name'] as String,
      totalPurchases: (e['total_purchases'] as num).toDouble(),
    )).toList();
  }
}
