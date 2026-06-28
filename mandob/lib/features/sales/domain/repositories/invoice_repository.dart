import '../entities/invoice.dart';
import '../entities/invoice_item.dart';
import '../entities/last_price.dart';

abstract class InvoiceRepository {
  Future<int> createInvoice(Invoice invoice, List<InvoiceItem> items);
  Future<List<Invoice>> getInvoices({String? date, int? customerId, String? query});
  Future<double> getTotalSales({String? date});
  Future<double> getTotalCash({String? date});
  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId);
  Future<Invoice?> getInvoiceById(int id);
  Future<LastPrice?> getLastPrice(int productId, int customerId);
  Future<void> cancelInvoice(int invoiceId);
}
