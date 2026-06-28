import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/services/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/products/presentation/cubit/product_cubit.dart';
import 'features/customers/presentation/cubit/customer_cubit.dart';
import 'features/stock/presentation/cubit/stock_cubit.dart';
import 'features/sales/presentation/cubit/invoice_cubit.dart';
import 'features/sales/presentation/cubit/new_invoice_cubit.dart';
import 'features/expenses/presentation/cubit/expense_cubit.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/collections/presentation/cubit/collection_cubit.dart';
import 'features/reports/presentation/cubit/reports_cubit.dart';
import 'features/backup/presentation/cubit/backup_cubit.dart';
import 'features/warehouses/presentation/cubit/warehouse_cubit.dart';
import 'features/warehouses/presentation/cubit/supplier_invoice_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [  
        BlocProvider(create: (context) => sl<ProductCubit>()),
        BlocProvider(create: (context) => sl<CustomerCubit>()),
        BlocProvider(create: (context) => sl<StockCubit>()),
        BlocProvider(create: (context) => sl<InvoiceCubit>()),
        BlocProvider(create: (context) => sl<NewInvoiceCubit>()),
        BlocProvider(create: (context) => sl<ExpenseCubit>()),
        BlocProvider(create: (context) => sl<DashboardCubit>()),
        BlocProvider(create: (context) => sl<CollectionCubit>()),
        BlocProvider(create: (context) => sl<ReportsCubit>()),
        BlocProvider(create: (context) => sl<BackupCubit>()),
        BlocProvider(create: (context) => sl<WarehouseCubit>()),
        BlocProvider(create: (context) => sl<SupplierInvoiceCubit>()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'EG'), // Arabic, Egypt
        ],
        locale: const Locale('ar', 'EG'),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
