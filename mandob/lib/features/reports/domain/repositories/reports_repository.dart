import '../entities/report_entities.dart';

abstract class ReportsRepository {
  Future<ProfitReport> getProfitReport({String? startDate, String? endDate});
  Future<List<ProductSalesReport>> getTopSellingProducts({String? startDate, String? endDate, int limit = 10});
  Future<List<CustomerSalesReport>> getTopCustomers({String? startDate, String? endDate, int limit = 10});
}
