import '../entities/report_entities.dart';
import '../repositories/reports_repository.dart';

class GetTopCustomers {
  final ReportsRepository repository;

  GetTopCustomers(this.repository);

  Future<List<CustomerSalesReport>> call({String? startDate, String? endDate, int limit = 10}) {
    return repository.getTopCustomers(startDate: startDate, endDate: endDate, limit: limit);
  }
}
