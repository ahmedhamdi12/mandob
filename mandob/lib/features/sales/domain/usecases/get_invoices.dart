import '../entities/invoice.dart';
import '../repositories/invoice_repository.dart';

class GetInvoices {
  final InvoiceRepository repository;

  GetInvoices(this.repository);

  Future<List<Invoice>> call({String? date, int? customerId, String? query}) {
    return repository.getInvoices(date: date, customerId: customerId, query: query);
  }
}
