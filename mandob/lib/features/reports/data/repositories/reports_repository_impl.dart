import '../../domain/entities/report_entities.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_local_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsLocalDataSource localDataSource;

  ReportsRepositoryImpl({required this.localDataSource});

  @override
  Future<ProfitReport> getProfitReport({String? startDate, String? endDate}) {
    return localDataSource.getProfitReport(startDate: startDate, endDate: endDate);
  }

  @override
  Future<List<ProductSalesReport>> getTopSellingProducts({String? startDate, String? endDate, int limit = 10}) {
    return localDataSource.getTopSellingProducts(startDate: startDate, endDate: endDate, limit: limit);
  }

  @override
  Future<List<CustomerSalesReport>> getTopCustomers({String? startDate, String? endDate, int limit = 10}) {
    return localDataSource.getTopCustomers(startDate: startDate, endDate: endDate, limit: limit);
  }
}
