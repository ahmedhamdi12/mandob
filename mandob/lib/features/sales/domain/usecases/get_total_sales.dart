import '../repositories/invoice_repository.dart';

class GetTotalSales {
  final InvoiceRepository repository;

  GetTotalSales(this.repository);

  Future<double> call({String? date}) {
    return repository.getTotalSales(date: date);
  }
}
