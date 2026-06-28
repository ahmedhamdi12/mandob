import 'package:equatable/equatable.dart';

class ProfitReport extends Equatable {
  final double totalSales;
  final double totalCosts;
  final double netProfit;

  const ProfitReport({
    required this.totalSales,
    required this.totalCosts,
    required this.netProfit,
  });

  @override
  List<Object?> get props => [totalSales, totalCosts, netProfit];
}

class ProductSalesReport extends Equatable {
  final int productId;
  final String productName;
  final double totalQtySold;
  final double totalRevenue;

  const ProductSalesReport({
    required this.productId,
    required this.productName,
    required this.totalQtySold,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [productId, productName, totalQtySold, totalRevenue];
}

class CustomerSalesReport extends Equatable {
  final int customerId;
  final String customerName;
  final double totalPurchases;

  const CustomerSalesReport({
    required this.customerId,
    required this.customerName,
    required this.totalPurchases,
  });

  @override
  List<Object?> get props => [customerId, customerName, totalPurchases];
}
