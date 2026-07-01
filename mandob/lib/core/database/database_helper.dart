import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_tables.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE ${DatabaseTables.customers} ADD COLUMN address TEXT DEFAULT ""');
      await db.execute('ALTER TABLE ${DatabaseTables.customers} ADD COLUMN current_balance REAL DEFAULT 0.0');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE ${DatabaseTables.stockPurchases} ADD COLUMN remaining_qty INTEGER NOT NULL DEFAULT 0');
      // Initialize remaining_qty to qty_units for existing records (fallback assuming they are not sold yet, 
      // or at least to give them a valid starting point if they were already sold it's hard to track retroactively perfectly without complex scripts)
      await db.execute('UPDATE ${DatabaseTables.stockPurchases} SET remaining_qty = qty_units');
    }
    if (oldVersion < 4) {
      await _createWarehouseTables(db);
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE ${DatabaseTables.invoices} ADD COLUMN type TEXT NOT NULL DEFAULT "sale"');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE ${DatabaseTables.supplierInvoiceItems} ADD COLUMN product_id INTEGER');
      await db.execute('ALTER TABLE ${DatabaseTables.supplierInvoiceItems} ADD COLUMN unit_id INTEGER');
      await db.execute('ALTER TABLE ${DatabaseTables.supplierInvoiceItems} ADD COLUMN qty_units INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // Products
    await db.execute('''
      CREATE TABLE ${DatabaseTables.products} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        base_unit TEXT NOT NULL DEFAULT 'قطعة',
        low_stock_threshold INTEGER NOT NULL DEFAULT 10,
        stock_qty INTEGER NOT NULL DEFAULT 0,
        average_cost REAL NOT NULL DEFAULT 0.0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (datetime('now','localtime'))
      )
    ''');

    // Product Units
    await db.execute('''
      CREATE TABLE ${DatabaseTables.productUnits} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        unit_name TEXT NOT NULL,
        conversion_factor INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (product_id) REFERENCES ${DatabaseTables.products}(id) ON DELETE CASCADE
      )
    ''');

    // Customers
    await db.execute('''
      CREATE TABLE ${DatabaseTables.customers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        region TEXT,
        address TEXT DEFAULT "",
        current_balance REAL DEFAULT 0.0,
        created_at TEXT NOT NULL DEFAULT (datetime('now','localtime'))
      )
    ''');

    // Invoices
    await db.execute('''
      CREATE TABLE ${DatabaseTables.invoices} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL DEFAULT 'sale',
        customer_id INTEGER NOT NULL,
        invoice_date TEXT NOT NULL,
        total_amount REAL NOT NULL DEFAULT 0,
        paid_amount REAL NOT NULL DEFAULT 0,
        remaining REAL NOT NULL DEFAULT 0,
        payment_type TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (customer_id) REFERENCES ${DatabaseTables.customers}(id)
      )
    ''');

    // Invoice Items
    await db.execute('''
      CREATE TABLE ${DatabaseTables.invoiceItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        qty_units INTEGER NOT NULL,
        unit_id INTEGER,
        display_qty REAL,
        unit_price REAL NOT NULL,
        cost_at_sale REAL NOT NULL,
        line_total REAL NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES ${DatabaseTables.invoices}(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES ${DatabaseTables.products}(id)
      )
    ''');

    // Collections
    await db.execute('''
      CREATE TABLE ${DatabaseTables.collections} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        invoice_id INTEGER,
        amount REAL NOT NULL,
        collect_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (customer_id) REFERENCES ${DatabaseTables.customers}(id),
        FOREIGN KEY (invoice_id) REFERENCES ${DatabaseTables.invoices}(id)
      )
    ''');

    // Stock Purchases
    await db.execute('''
      CREATE TABLE ${DatabaseTables.stockPurchases} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        qty_units INTEGER NOT NULL,
        cost_per_unit REAL NOT NULL,
        purchase_date TEXT NOT NULL,
        notes TEXT,
        remaining_qty INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (product_id) REFERENCES ${DatabaseTables.products}(id)
      )
    ''');

    // Last Prices
    await db.execute('''
      CREATE TABLE ${DatabaseTables.lastPrices} (
        product_id INTEGER NOT NULL,
        customer_id INTEGER NOT NULL,
        unit_id INTEGER,
        last_price REAL NOT NULL,
        updated_at TEXT NOT NULL DEFAULT (datetime('now','localtime')),
        PRIMARY KEY (product_id, customer_id),
        FOREIGN KEY (product_id) REFERENCES ${DatabaseTables.products}(id),
        FOREIGN KEY (customer_id) REFERENCES ${DatabaseTables.customers}(id)
      )
    ''');

    // Stock Movements
    await db.execute('''
      CREATE TABLE ${DatabaseTables.stockMovements} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        qty INTEGER NOT NULL,
        reference_id INTEGER,
        created_at TEXT NOT NULL DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (product_id) REFERENCES ${DatabaseTables.products}(id)
      )
    ''');

    // Expenses
    await db.execute('''
      CREATE TABLE ${DatabaseTables.expenses} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        expense_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now','localtime'))
      )
    ''');

    await _createWarehouseTables(db);

    // Indexes
    await db.execute('CREATE INDEX idx_products_name ON ${DatabaseTables.products}(name)');
    await db.execute('CREATE INDEX idx_products_is_deleted ON ${DatabaseTables.products}(is_deleted)');
    await db.execute('CREATE INDEX idx_customers_name ON ${DatabaseTables.customers}(name)');
    await db.execute('CREATE INDEX idx_invoice_date ON ${DatabaseTables.invoices}(invoice_date)');
    await db.execute('CREATE INDEX idx_invoice_customer ON ${DatabaseTables.invoices}(customer_id)');
    await db.execute('CREATE INDEX idx_invoice_status ON ${DatabaseTables.invoices}(status)');
    await db.execute('CREATE INDEX idx_invoice_items_invoice ON ${DatabaseTables.invoiceItems}(invoice_id)');
    await db.execute('CREATE INDEX idx_stock_movements_product ON ${DatabaseTables.stockMovements}(product_id)');
    await db.execute('CREATE INDEX idx_stock_movements_type ON ${DatabaseTables.stockMovements}(type)');
    await db.execute('CREATE INDEX idx_expenses_date ON ${DatabaseTables.expenses}(expense_date)');
    await db.execute('CREATE INDEX idx_expenses_category ON ${DatabaseTables.expenses}(category)');
    
    // Warehouse Indexes
    await db.execute('CREATE INDEX idx_suppliers_name ON ${DatabaseTables.suppliers}(name)');
    await db.execute('CREATE INDEX idx_supplier_invoices_date ON ${DatabaseTables.supplierInvoices}(invoice_date)');
    await db.execute('CREATE INDEX idx_supplier_invoices_supplier ON ${DatabaseTables.supplierInvoices}(supplier_id)');
  }

  Future _createWarehouseTables(Database db) async {
    // Suppliers (Warehouses/Factories)
    await db.execute('''
      CREATE TABLE ${DatabaseTables.suppliers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT DEFAULT "",
        current_balance REAL DEFAULT 0.0,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now','localtime'))
      )
    ''');

    // Supplier Invoices (Purchases & Returns)
    await db.execute('''
      CREATE TABLE ${DatabaseTables.supplierInvoices} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL UNIQUE,
        supplier_id INTEGER NOT NULL,
        type TEXT NOT NULL DEFAULT 'purchase',
        invoice_date TEXT NOT NULL,
        total_amount REAL NOT NULL DEFAULT 0,
        paid_amount REAL NOT NULL DEFAULT 0,
        remaining REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'active',
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (supplier_id) REFERENCES ${DatabaseTables.suppliers}(id)
      )
    ''');

    // Supplier Invoice Items
    await db.execute('''
      CREATE TABLE ${DatabaseTables.supplierInvoiceItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        product_id INTEGER,
        item_name TEXT NOT NULL,
        qty REAL NOT NULL,
        unit_id INTEGER,
        qty_units INTEGER NOT NULL DEFAULT 0,
        unit_price REAL NOT NULL,
        line_total REAL NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES ${DatabaseTables.supplierInvoices}(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES ${DatabaseTables.products}(id)
      )
    ''');

    // Supplier Payments
    await db.execute('''
      CREATE TABLE ${DatabaseTables.supplierPayments} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supplier_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (supplier_id) REFERENCES ${DatabaseTables.suppliers}(id)
      )
    ''');
  }

  // --- Utility method to fix out-of-sync batches (Data cleanup tool) ---
  Future<void> syncFIFOStock() async {
    final db = await database;
    await db.transaction((txn) async {
      final products = await txn.query(DatabaseTables.products, columns: ['id', 'stock_qty']);
      
      for (var product in products) {
        final productId = product['id'] as int;
        final stockQty = product['stock_qty'] as int;
        
        // Find how many batches we have
        final batches = await txn.query(
          DatabaseTables.stockPurchases,
          where: 'product_id = ?',
          whereArgs: [productId],
          orderBy: 'purchase_date DESC, id DESC',
        );

        int remainingToAllocate = stockQty;
        
        for (var batch in batches) {
          final batchId = batch['id'] as int;
          final qtyUnits = batch['qty_units'] as int;
          
          int newRemaining = 0;
          if (remainingToAllocate > 0) {
            if (remainingToAllocate >= qtyUnits) {
              newRemaining = qtyUnits;
              remainingToAllocate -= qtyUnits;
            } else {
              newRemaining = remainingToAllocate;
              remainingToAllocate = 0;
            }
          }
          
          await txn.update(
            DatabaseTables.stockPurchases,
            {'remaining_qty': newRemaining},
            where: 'id = ?',
            whereArgs: [batchId],
          );
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> getActiveInventoryBatches() async {
    final db = await database;
    final sql = '''
      SELECT 
        p.id as product_id,
        p.name as product_name,
        p.base_unit,
        sp.purchase_date,
        sp.remaining_qty,
        sp.cost_per_unit,
        (sp.remaining_qty * sp.cost_per_unit) as batch_value
      FROM ${DatabaseTables.stockPurchases} sp
      JOIN ${DatabaseTables.products} p ON sp.product_id = p.id
      WHERE sp.remaining_qty > 0 AND p.is_deleted = 0
      ORDER BY p.name ASC, sp.purchase_date ASC
    ''';
    return await db.rawQuery(sql);
  }
}
