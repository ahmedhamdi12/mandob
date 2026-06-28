import '../entities/last_price.dart';
import '../repositories/invoice_repository.dart';

class GetLastPrice {
  final InvoiceRepository repository;

  GetLastPrice(this.repository);

  Future<LastPrice?> call(int productId, int customerId) {
    return repository.getLastPrice(productId, customerId);
  }
}
