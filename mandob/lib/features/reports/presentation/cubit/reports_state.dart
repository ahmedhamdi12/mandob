import 'package:equatable/equatable.dart';
import '../../domain/entities/report_entities.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final ProfitReport profitReport;
  final List<ProductSalesReport> topProducts;
  final List<CustomerSalesReport> topCustomers;
  final String dateRangeLabel;

  const ReportsLoaded({
    required this.profitReport,
    required this.topProducts,
    required this.topCustomers,
    required this.dateRangeLabel,
  });

  @override
  List<Object?> get props => [profitReport, topProducts, topCustomers, dateRangeLabel];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
