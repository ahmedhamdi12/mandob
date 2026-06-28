import '../entities/report_entities.dart';
import '../repositories/reports_repository.dart';

class GetTopSellingProducts {
  final ReportsRepository repository;

  GetTopSellingProducts(this.repository);

  Future<List<ProductSalesReport>> call({String? startDate, String? endDate, int limit = 10}) {
    return repository.getTopSellingProducts(startDate: startDate, endDate: endDate, limit: limit);
  }
}
