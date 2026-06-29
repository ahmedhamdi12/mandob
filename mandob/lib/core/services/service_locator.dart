import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';

// Products
import '../../features/products/data/datasources/product_local_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/add_product.dart';
import '../../features/products/domain/usecases/delete_product.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/update_product.dart';
import '../../features/products/presentation/cubit/product_cubit.dart';

// Customers
import '../../features/customers/data/datasources/customer_local_datasource.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/add_customer.dart';
import '../../features/customers/domain/usecases/delete_customer.dart';
import '../../features/customers/domain/usecases/get_customers.dart';
import '../../features/customers/domain/usecases/update_customer.dart';
import '../../features/customers/presentation/cubit/customer_cubit.dart';

// Stock
import '../../features/stock/data/datasources/stock_local_datasource.dart';
import '../../features/stock/data/repositories/stock_repository_impl.dart';
import '../../features/stock/domain/repositories/stock_repository.dart';
import '../../features/stock/domain/usecases/add_stock_purchase.dart';
import '../../features/stock/domain/usecases/get_stock_movements.dart';
import '../../features/stock/domain/usecases/return_stock.dart';
import '../../features/stock/presentation/cubit/stock_cubit.dart';

// Sales
import '../../features/sales/data/datasources/invoice_local_datasource.dart';
import '../../features/sales/data/repositories/invoice_repository_impl.dart';
import '../../features/sales/domain/repositories/invoice_repository.dart';
import '../../features/sales/domain/usecases/create_invoice.dart';
import '../../features/sales/domain/usecases/get_invoices.dart';
import '../../features/sales/domain/usecases/get_total_sales.dart';
import '../../features/sales/domain/usecases/get_total_cash.dart';
import '../../features/sales/domain/usecases/get_invoice_details.dart';
import '../../features/sales/domain/usecases/get_last_price.dart';
import '../../features/sales/presentation/cubit/invoice_cubit.dart';
import '../../features/sales/presentation/cubit/new_invoice_cubit.dart';

// Expenses
import '../../features/expenses/data/datasources/expense_local_datasource.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/domain/usecases/add_expense.dart';
import '../../features/expenses/domain/usecases/get_expenses.dart';
import '../../features/expenses/domain/usecases/get_total_expenses.dart';
import '../../features/expenses/presentation/cubit/expense_cubit.dart';

// Dashboard
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';

// Collections
import '../../features/collections/data/datasources/collection_local_datasource.dart';
import '../../features/collections/data/repositories/collection_repository_impl.dart';
import '../../features/collections/domain/repositories/collection_repository.dart';
import '../../features/collections/domain/usecases/add_collection.dart';
import '../../features/collections/domain/usecases/get_collections.dart';
import '../../features/collections/domain/usecases/get_total_debts.dart';
import '../../features/collections/domain/usecases/get_customer_debt.dart';
import '../../features/collections/presentation/cubit/collection_cubit.dart';

// Reports
import '../../features/reports/data/datasources/reports_local_datasource.dart';
import '../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../features/reports/domain/repositories/reports_repository.dart';
import '../../features/reports/domain/usecases/get_profit_report.dart';
import '../../features/reports/domain/usecases/get_top_selling_products.dart';
import '../../features/reports/domain/usecases/get_top_customers.dart';
import '../../features/reports/presentation/cubit/reports_cubit.dart';

// Backup
import '../../features/backup/domain/services/backup_service.dart';
import '../../features/backup/presentation/cubit/backup_cubit.dart';

// Warehouses
import '../../features/warehouses/data/datasources/warehouse_local_datasource.dart';
import '../../features/warehouses/data/repositories/warehouse_repository_impl.dart';
import '../../features/warehouses/domain/repositories/warehouse_repository.dart';
import '../../features/warehouses/domain/usecases/get_suppliers.dart';
import '../../features/warehouses/domain/usecases/add_supplier.dart';
import '../../features/warehouses/domain/usecases/update_supplier.dart';
import '../../features/warehouses/domain/usecases/delete_supplier.dart';
import '../../features/warehouses/domain/usecases/create_supplier_invoice.dart';
import '../../features/warehouses/domain/usecases/get_supplier_invoices.dart';
import '../../features/warehouses/domain/usecases/cancel_supplier_invoice.dart';
import '../../features/warehouses/domain/usecases/add_supplier_payment.dart';
import '../../features/warehouses/domain/usecases/get_supplier_payments.dart';
import '../../features/warehouses/presentation/cubit/warehouse_cubit.dart';
import '../../features/warehouses/presentation/cubit/supplier_invoice_cubit.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Core
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

  // Features - Products
  // Data sources
  sl.registerLazySingleton<ProductLocalDataSource>(
      () => ProductLocalDataSource(dbHelper: sl()));

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(localDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => AddProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));

  // Cubit
  sl.registerFactory(() => ProductCubit(
        getProductsUseCase: sl(),
        addProductUseCase: sl(),
        updateProductUseCase: sl(),
        deleteProductUseCase: sl(),
      ));

  // Features - Customers
  // Data sources
  sl.registerLazySingleton<CustomerLocalDataSource>(
      () => CustomerLocalDataSource(dbHelper: sl()));

  // Repositories
  sl.registerLazySingleton<CustomerRepository>(
      () => CustomerRepositoryImpl(localDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetCustomers(sl()));
  sl.registerLazySingleton(() => AddCustomer(sl()));
  sl.registerLazySingleton(() => UpdateCustomer(sl()));
  sl.registerLazySingleton(() => DeleteCustomer(sl()));

  // Cubit
  sl.registerFactory(() => CustomerCubit(
        getCustomersUseCase: sl(),
        addCustomerUseCase: sl(),
        updateCustomerUseCase: sl(),
        deleteCustomerUseCase: sl(),
      ));

  // Features - Stock
  // Data sources
  sl.registerLazySingleton<StockLocalDataSource>(
      () => StockLocalDataSource(dbHelper: sl()));

  // Repositories
  sl.registerLazySingleton<StockRepository>(
      () => StockRepositoryImpl(localDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => AddStockPurchase(sl()));
  sl.registerLazySingleton(() => GetStockMovements(sl()));
  sl.registerLazySingleton(() => ReturnStock(sl()));

  // Cubit
  sl.registerFactory(() => StockCubit(
        addStockPurchaseUseCase: sl(),
        returnStockUseCase: sl(),
      ));

  // Features - Sales
  // Data sources
  sl.registerLazySingleton<InvoiceLocalDataSource>(
      () => InvoiceLocalDataSource(dbHelper: sl()));

  // Repositories
  sl.registerLazySingleton<InvoiceRepository>(
      () => InvoiceRepositoryImpl(localDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => CreateInvoice(sl()));
  sl.registerLazySingleton(() => GetInvoices(sl()));
  sl.registerLazySingleton(() => GetTotalSales(sl()));
  sl.registerLazySingleton(() => GetTotalCash(sl()));
  sl.registerLazySingleton(() => GetInvoiceDetails(sl()));
  sl.registerLazySingleton(() => GetLastPrice(sl()));

  // Cubits
  sl.registerFactory(() => InvoiceCubit(
        getInvoicesUseCase: sl(),
        repository: sl(),
      ));
  sl.registerFactory(() => NewInvoiceCubit(
        createInvoiceUseCase: sl(),
        getLastPriceUseCase: sl(),
      ));

  // Features - Expenses
  // Data sources
  sl.registerLazySingleton<ExpenseLocalDataSource>(
      () => ExpenseLocalDataSource(dbHelper: sl()));

  // Repositories
  sl.registerLazySingleton<ExpenseRepository>(
      () => ExpenseRepositoryImpl(localDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => AddExpense(sl()));
  sl.registerLazySingleton(() => GetExpenses(sl()));
  sl.registerLazySingleton(() => GetTotalExpenses(sl()));

  // Cubits
  sl.registerFactory(() => ExpenseCubit(
        addExpenseUseCase: sl(),
        getExpensesUseCase: sl(),
        getTotalExpensesUseCase: sl(),
      ));

  // Features - Dashboard
  sl.registerFactory(() => DashboardCubit(
        getTotalSalesUseCase: sl(),
        getTotalCashUseCase: sl(),
        getTotalExpensesUseCase: sl(),
        getTotalDebtsUseCase: sl(),
      ));

  // Features - Collections
  // Data sources
  sl.registerLazySingleton<CollectionLocalDataSource>(
      () => CollectionLocalDataSource(dbHelper: sl()));

  // Repositories
  sl.registerLazySingleton<CollectionRepository>(
      () => CollectionRepositoryImpl(localDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => AddCollection(sl()));
  sl.registerLazySingleton(() => GetCollections(sl()));
  sl.registerLazySingleton(() => GetTotalDebts(sl()));
  sl.registerLazySingleton(() => GetCustomerDebt(sl()));

  // Cubits
  sl.registerFactory(() => CollectionCubit(
        addCollectionUseCase: sl(),
        getCollectionsUseCase: sl(),
        getTotalDebtsUseCase: sl(),
        getCustomerDebtUseCase: sl(),
      ));

  // Features - Reports
  // Data sources
  sl.registerLazySingleton<ReportsLocalDataSource>(
      () => ReportsLocalDataSource(dbHelper: sl()));

  // Repositories
  sl.registerLazySingleton<ReportsRepository>(
      () => ReportsRepositoryImpl(localDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetProfitReport(sl()));
  sl.registerLazySingleton(() => GetTopSellingProducts(sl()));
  sl.registerLazySingleton(() => GetTopCustomers(sl()));

  // Cubits
  sl.registerFactory(() => ReportsCubit(
        getProfitReportUseCase: sl(),
        getTopSellingProductsUseCase: sl(),
        getTopCustomersUseCase: sl(),
      ));

  // Features - Backup
  sl.registerLazySingleton(() => BackupService());
  sl.registerFactory(() => BackupCubit(backupService: sl()));

  // Features - Warehouses
  // Data sources
  sl.registerLazySingleton<WarehouseLocalDataSource>(
      () => WarehouseLocalDataSource(dbHelper: sl()));

  // Repositories
  sl.registerLazySingleton<WarehouseRepository>(
      () => WarehouseRepositoryImpl(localDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetSuppliers(sl()));
  sl.registerLazySingleton(() => AddSupplier(sl()));
  sl.registerLazySingleton(() => UpdateSupplier(sl()));
  sl.registerLazySingleton(() => DeleteSupplier(sl()));
  sl.registerLazySingleton(() => CreateSupplierInvoice(sl()));
  sl.registerLazySingleton(() => GetSupplierInvoices(sl()));
  sl.registerLazySingleton(() => CancelSupplierInvoice(sl()));
  sl.registerLazySingleton(() => AddSupplierPayment(sl()));
  sl.registerLazySingleton(() => GetSupplierPayments(sl()));

  // Cubits
  sl.registerFactory(() => WarehouseCubit(
        getSuppliersUseCase: sl(),
        addSupplierUseCase: sl(),
        updateSupplierUseCase: sl(),
        deleteSupplierUseCase: sl(),
        getSupplierInvoicesUseCase: sl(),
        getSupplierPaymentsUseCase: sl(),
        addSupplierPaymentUseCase: sl(),
        cancelSupplierInvoiceUseCase: sl(),
        repository: sl(),
      ));
  sl.registerFactory(() => SupplierInvoiceCubit(
        createSupplierInvoiceUseCase: sl(),
      ));
}
