import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double todaySales;
  final double todayCash;
  final double todayExpenses;
  final double netResult;
  final double totalDebts;

  const DashboardLoaded({
    required this.todaySales,
    required this.todayCash,
    required this.todayExpenses,
    required this.netResult,
    required this.totalDebts,
  });

  @override
  List<Object> get props => [todaySales, todayCash, todayExpenses, netResult, totalDebts];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
