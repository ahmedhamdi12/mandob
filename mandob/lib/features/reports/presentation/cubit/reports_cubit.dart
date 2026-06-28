import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profit_report.dart';
import '../../domain/usecases/get_top_selling_products.dart';
import '../../domain/usecases/get_top_customers.dart';
import 'reports_state.dart';
import '../../../../core/utils/date_utils.dart';

enum ReportPeriod { today, thisMonth, allTime, custom }

class ReportsCubit extends Cubit<ReportsState> {
  final GetProfitReport getProfitReportUseCase;
  final GetTopSellingProducts getTopSellingProductsUseCase;
  final GetTopCustomers getTopCustomersUseCase;

  ReportPeriod currentPeriod = ReportPeriod.thisMonth;
  String? customStartDate;
  String? customEndDate;

  ReportsCubit({
    required this.getProfitReportUseCase,
    required this.getTopSellingProductsUseCase,
    required this.getTopCustomersUseCase,
  }) : super(ReportsInitial());

  Future<void> loadReports({ReportPeriod? period, String? start, String? end}) async {
    emit(ReportsLoading());
    try {
      if (period != null) currentPeriod = period;
      if (start != null) customStartDate = start;
      if (end != null) customEndDate = end;

      String? startDateFilter;
      String? endDateFilter;
      String label = '';

      final now = DateTime.now();

      switch (currentPeriod) {
        case ReportPeriod.today:
          startDateFilter = AppDateUtils.getCurrentIso().split('T').first;
          endDateFilter = startDateFilter;
          label = 'اليوم';
          break;
        case ReportPeriod.thisMonth:
          startDateFilter = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
          endDateFilter = AppDateUtils.getCurrentIso().split('T').first;
          label = 'الشهر الحالي';
          break;
        case ReportPeriod.allTime:
          startDateFilter = null;
          endDateFilter = null;
          label = 'كل الوقت';
          break;
        case ReportPeriod.custom:
          startDateFilter = customStartDate;
          endDateFilter = customEndDate;
          label = 'فترة مخصصة';
          break;
      }

      final profit = await getProfitReportUseCase(startDate: startDateFilter, endDate: endDateFilter);
      final products = await getTopSellingProductsUseCase(startDate: startDateFilter, endDate: endDateFilter);
      final customers = await getTopCustomersUseCase(startDate: startDateFilter, endDate: endDateFilter);

      emit(ReportsLoaded(
        profitReport: profit,
        topProducts: products,
        topCustomers: customers,
        dateRangeLabel: label,
      ));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }
}
