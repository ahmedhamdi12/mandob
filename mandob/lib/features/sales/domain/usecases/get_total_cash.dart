import '../repositories/invoice_repository.dart';

class GetTotalCash {
  final InvoiceRepository repository;

  GetTotalCash(this.repository);

  Future<double> call({String? date}) {
    return repository.getTotalCash(date: date);
  }
}
