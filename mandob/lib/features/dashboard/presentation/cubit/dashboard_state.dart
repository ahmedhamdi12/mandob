import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class MonthSummary extends Equatable {
  final String yearMonth;
  final double sales;
  final double expenses;
  final double netResult;

  const MonthSummary({
    required this.yearMonth,
    required this.sales,
    required this.expenses,
    required this.netResult,
  });

  @override
  List<Object> get props => [yearMonth, sales, expenses, netResult];
}

class DashboardLoaded extends DashboardState {
  final double todaySales;
  final double monthlySales;
  final double monthlyCash;
  final double monthlyExpenses;
  final double monthlyNetResult;
  final double totalDebts;
  final List<MonthSummary> previousMonths;

  const DashboardLoaded({
    required this.todaySales,
    required this.monthlySales,
    required this.monthlyCash,
    required this.monthlyExpenses,
    required this.monthlyNetResult,
    required this.totalDebts,
    required this.previousMonths,
  });

  @override
  List<Object> get props => [
        todaySales,
        monthlySales,
        monthlyCash,
        monthlyExpenses,
        monthlyNetResult,
        totalDebts,
        previousMonths,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
