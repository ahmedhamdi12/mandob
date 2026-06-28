import '../entities/report_entities.dart';
import '../repositories/reports_repository.dart';

class GetProfitReport {
  final ReportsRepository repository;

  GetProfitReport(this.repository);

  Future<ProfitReport> call({String? startDate, String? endDate}) {
    return repository.getProfitReport(startDate: startDate, endDate: endDate);
  }
}
