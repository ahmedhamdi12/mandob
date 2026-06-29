import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../main_shell.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/products/presentation/screens/add_edit_product_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/inventory_audit_screen.dart';
import '../../features/customers/presentation/screens/customers_screen.dart';
import '../../features/customers/presentation/screens/add_edit_customer_screen.dart';
import '../../features/stock/presentation/screens/stock_entry_screen.dart';
import '../../features/stock/presentation/screens/stock_return_screen.dart';
import '../../features/sales/presentation/screens/invoices_screen.dart';
import '../../features/sales/presentation/screens/new_invoice_screen.dart';
import '../../features/sales/presentation/screens/invoice_details_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/expenses/presentation/screens/add_expense_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/collections/presentation/screens/collections_screen.dart';
import '../../features/collections/presentation/screens/add_collection_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/backup/presentation/screens/backup_screen.dart';
import '../../features/warehouses/presentation/screens/warehouse_home_screen.dart';
import '../../features/warehouses/presentation/screens/add_edit_supplier_screen.dart';
import '../../features/warehouses/presentation/screens/supplier_details_screen.dart';
import '../../features/warehouses/presentation/screens/new_supplier_invoice_screen.dart';
import '../../features/warehouses/presentation/screens/supplier_invoice_details_screen.dart';

// Dummy screens for now to prevent errors
class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text(title)));
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductsScreen(),
        ),
        GoRoute(
          path: '/invoices',
          builder: (context, state) => const InvoicesScreen(),
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomersScreen(),
        ),
        GoRoute(
          path: '/expenses',
          builder: (context, state) => const ExpensesScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/products/add',
      builder: (context, state) => const AddEditProductScreen(),
    ),
    GoRoute(
      path: '/products/edit/:id',
      builder: (context, state) => AddEditProductScreen(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/products/details/:id',
      builder: (context, state) => ProductDetailScreen(productId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/products/inventory',
      builder: (context, state) => const InventoryAuditScreen(),
    ),
    GoRoute(
      path: '/customers/add',
      builder: (context, state) => const AddEditCustomerScreen(),
    ),
    GoRoute(
      path: '/customers/edit/:id',
      builder: (context, state) => AddEditCustomerScreen(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/stock/entry',
      builder: (context, state) => const StockEntryScreen(),
    ),
    GoRoute(
      path: '/stock/return',
      builder: (context, state) => const StockReturnScreen(),
    ),

    GoRoute(
      path: '/invoices/new',
      builder: (context, state) => const NewInvoiceScreen(isReturn: false),
    ),
    GoRoute(
      path: '/invoices/new-return',
      builder: (context, state) => const NewInvoiceScreen(isReturn: true),
    ),
    GoRoute(
      path: '/invoices/details/:id',
      builder: (context, state) => InvoiceDetailsScreen(invoiceId: int.parse(state.pathParameters['id']!)),
    ),

    GoRoute(
      path: '/expenses/new',
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/collections',
      builder: (context, state) => const CollectionsScreen(),
    ),
    GoRoute(
      path: '/collections/new',
      builder: (context, state) => const AddCollectionScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/backup',
      builder: (context, state) => const BackupScreen(),
    ),
    
    // Warehouses Module
    GoRoute(
      path: '/warehouses',
      builder: (context, state) => const WarehouseHomeScreen(),
    ),
    GoRoute(
      path: '/warehouses/suppliers/add',
      builder: (context, state) => const AddEditSupplierScreen(),
    ),
    GoRoute(
      path: '/warehouses/suppliers/edit/:id',
      builder: (context, state) => AddEditSupplierScreen(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/warehouses/suppliers/:id',
      builder: (context, state) => SupplierDetailsScreen(supplierId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/warehouses/invoices/new',
      builder: (context, state) => const NewSupplierInvoiceScreen(isReturn: false),
    ),
    GoRoute(
      path: '/warehouses/invoices/new-return',
      builder: (context, state) => const NewSupplierInvoiceScreen(isReturn: true),
    ),
    GoRoute(
      path: '/warehouses/invoices/:id',
      builder: (context, state) => SupplierInvoiceDetailsScreen(invoiceId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);
