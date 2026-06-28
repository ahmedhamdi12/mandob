import '../entities/collection.dart';

abstract class CollectionRepository {
  Future<int> addCollection(Collection collection);
  Future<List<Collection>> getCollections({String? date, int? customerId});
  Future<List<Collection>> getCollectionsByInvoice(int invoiceId);
  Future<double> getTotalCollections({String? date});
  Future<double> getCustomerDebt(int customerId);
  Future<double> getTotalDebts();
}
