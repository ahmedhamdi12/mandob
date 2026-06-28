import '../entities/invoice_item.dart';
import '../repositories/invoice_repository.dart';

class GetInvoiceDetails {
  final InvoiceRepository repository;

  GetInvoiceDetails(this.repository);

  Future<List<InvoiceItem>> call(int invoiceId) {
    return repository.getInvoiceItems(invoiceId);
  }
}
