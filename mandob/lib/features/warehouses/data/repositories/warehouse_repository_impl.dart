import '../../domain/entities/supplier.dart';
import '../../domain/entities/supplier_invoice.dart';
import '../../domain/entities/supplier_invoice_item.dart';
import '../../domain/entities/supplier_payment.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../datasources/warehouse_local_datasource.dart';
import '../models/supplier_model.dart';
import '../models/supplier_invoice_model.dart';
import '../models/supplier_invoice_item_model.dart';
import '../models/supplier_payment_model.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final WarehouseLocalDataSource localDataSource;

  WarehouseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Supplier>> getSuppliers({String? query}) async {
    return await localDataSource.getSuppliers(query: query);
  }

  @override
  Future<Supplier?> getSupplierById(int id) async {
    return await localDataSource.getSupplierById(id);
  }

  @override
  Future<int> addSupplier(Supplier supplier) {
    return localDataSource.addSupplier(SupplierModel.fromEntity(supplier));
  }

  @override
  Future<void> updateSupplier(Supplier supplier) {
    return localDataSource.updateSupplier(SupplierModel.fromEntity(supplier));
  }

  @override
  Future<void> deleteSupplier(int id) {
    return localDataSource.deleteSupplier(id);
  }

  @override
  Future<int> createSupplierInvoice(SupplierInvoice invoice, List<SupplierInvoiceItem> items) {
    final invoiceModel = SupplierInvoiceModel.fromEntity(invoice);
    final itemModels = items.map((e) => SupplierInvoiceItemModel.fromEntity(e)).toList();
    return localDataSource.createSupplierInvoice(invoiceModel, itemModels);
  }

  @override
  Future<List<SupplierInvoice>> getSupplierInvoices({String? date, int? supplierId, String? query}) async {
    return await localDataSource.getSupplierInvoices(date: date, supplierId: supplierId, query: query);
  }

  @override
  Future<SupplierInvoice?> getSupplierInvoiceById(int id) async {
    return await localDataSource.getSupplierInvoiceById(id);
  }

  @override
  Future<List<SupplierInvoiceItem>> getSupplierInvoiceItems(int invoiceId) async {
    return await localDataSource.getSupplierInvoiceItems(invoiceId);
  }

  @override
  Future<void> cancelSupplierInvoice(int invoiceId) {
    return localDataSource.cancelSupplierInvoice(invoiceId);
  }

  @override
  Future<int> addSupplierPayment(SupplierPayment payment) {
    return localDataSource.addSupplierPayment(SupplierPaymentModel.fromEntity(payment));
  }

  @override
  Future<List<SupplierPayment>> getSupplierPayments({int? supplierId, String? date}) async {
    return await localDataSource.getSupplierPayments(supplierId: supplierId, date: date);
  }

  @override
  Future<double> getTotalSupplierDebts() {
    return localDataSource.getTotalSupplierDebts();
  }

  @override
  Future<double> getSupplierDebt(int supplierId) {
    return localDataSource.getSupplierDebt(supplierId);
  }
}
