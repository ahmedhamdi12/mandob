import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/entities/last_price.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoice_local_datasource.dart';
import '../models/invoice_model.dart';
import '../models/invoice_item_model.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceLocalDataSource localDataSource;

  InvoiceRepositoryImpl({required this.localDataSource});

  @override
  Future<void> cancelInvoice(int invoiceId) async {
    await localDataSource.cancelInvoice(invoiceId);
  }

  @override
  Future<int> createInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final invoiceModel = InvoiceModel.fromEntity(invoice);
    final itemModels = items.map((e) => InvoiceItemModel.fromEntity(e)).toList();
    return await localDataSource.createInvoice(invoiceModel, itemModels);
  }

  @override
  Future<Invoice?> getInvoiceById(int id) async {
    return await localDataSource.getInvoiceById(id);
  }

  @override
  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    return await localDataSource.getInvoiceItems(invoiceId);
  }

  @override
  Future<List<Invoice>> getInvoices({String? date, int? customerId, String? query}) async {
    return await localDataSource.getInvoices(date: date, customerId: customerId, query: query);
  }

  @override
  Future<double> getTotalSales({String? date}) async {
    return await localDataSource.getTotalSales(date: date);
  }

  @override
  Future<double> getTotalCash({String? date}) {
    return localDataSource.getTotalCollections(date: date);
  }

  @override
  Future<LastPrice?> getLastPrice(int productId, int customerId) async {
    return await localDataSource.getLastPrice(productId, customerId);
  }
}
