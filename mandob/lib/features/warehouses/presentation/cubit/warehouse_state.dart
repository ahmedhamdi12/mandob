abstract class WarehouseState {}

class WarehouseInitial extends WarehouseState {}

class WarehouseLoading extends WarehouseState {}

class WarehouseLoaded extends WarehouseState {
  final List<dynamic> suppliers;
  final List<dynamic> invoices;
  final List<dynamic> payments;
  final double totalDebt;

  WarehouseLoaded({
    required this.suppliers,
    required this.invoices,
    required this.payments,
    required this.totalDebt,
  });
}

class WarehouseError extends WarehouseState {
  final String message;
  WarehouseError(this.message);
}
