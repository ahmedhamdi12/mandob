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
      final todayStr = AppDateUtils.getCurrentIso().split('T').first;

      final todaySales = await getTotalSalesUseCase(date: todayStr);
      final todayCash = await getTotalCashUseCase(date: todayStr);
      final todayExpenses = await getTotalExpensesUseCase(date: todayStr);
      final totalDebts = await getTotalDebtsUseCase();
      
      final netResult = todaySales - todayExpenses;
      
      emit(DashboardLoaded(
        todaySales: todaySales,
        todayCash: todayCash,
        todayExpenses: todayExpenses,
        netResult: netResult,
        totalDebts: totalDebts,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
