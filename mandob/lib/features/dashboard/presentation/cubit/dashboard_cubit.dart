import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../sales/domain/usecases/get_total_sales.dart';
import '../../../sales/domain/usecases/get_total_cash.dart';
import '../../../expenses/domain/usecases/get_total_expenses.dart';
import '../../../collections/domain/usecases/get_total_debts.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetTotalSales getTotalSalesUseCase;
  final GetTotalCash getTotalCashUseCase;
  final GetTotalExpenses getTotalExpensesUseCase;
  final GetTotalDebts getTotalDebtsUseCase;

  DashboardCubit({
    required this.getTotalSalesUseCase,
    required this.getTotalCashUseCase,
    required this.getTotalExpensesUseCase,
    required this.getTotalDebtsUseCase,
  }) : super(DashboardInitial());

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    try {
      final now = DateTime.now();
      final todayStr = AppDateUtils.getCurrentIso().split('T').first;
      final currentMonthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      // Today's specific data
      final todaySales = await getTotalSalesUseCase(date: todayStr);

      // Current month's data
      final monthlySales = await getTotalSalesUseCase(date: currentMonthStr);
      final monthlyCash = await getTotalCashUseCase(date: currentMonthStr);
      final monthlyExpenses = await getTotalExpensesUseCase(date: currentMonthStr);
      final totalDebts = await getTotalDebtsUseCase();
      
      final monthlyNetResult = monthlySales - monthlyExpenses;

      // Previous 6 months data
      List<MonthSummary> previousMonths = [];
      for (int i = 1; i <= 6; i++) {
        var pastMonthDate = DateTime(now.year, now.month - i, 1);
        String yearMonthStr = '${pastMonthDate.year}-${pastMonthDate.month.toString().padLeft(2, '0')}';
        
        final pastSales = await getTotalSalesUseCase(date: yearMonthStr);
        final pastExpenses = await getTotalExpensesUseCase(date: yearMonthStr);
        final pastNetResult = pastSales - pastExpenses;
        
        // Only add if there is data
        if (pastSales > 0 || pastExpenses > 0) {
          previousMonths.add(MonthSummary(
            yearMonth: yearMonthStr,
            sales: pastSales,
            expenses: pastExpenses,
            netResult: pastNetResult,
          ));
        }
      }
      
      emit(DashboardLoaded(
        todaySales: todaySales,
        monthlySales: monthlySales,
        monthlyCash: monthlyCash,
        monthlyExpenses: monthlyExpenses,
        monthlyNetResult: monthlyNetResult,
        totalDebts: totalDebts,
        previousMonths: previousMonths,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
