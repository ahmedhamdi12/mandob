import '../entities/invoice.dart';
import '../entities/invoice_item.dart';
import '../repositories/invoice_repository.dart';

class CreateInvoice {
  final InvoiceRepository repository;

  CreateInvoice(this.repository);

  Future<int> call(Invoice invoice, List<InvoiceItem> items) {
    return repository.createInvoice(invoice, items);
  }
}
