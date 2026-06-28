import '../../domain/entities/collection.dart';
import '../../domain/repositories/collection_repository.dart';
import '../datasources/collection_local_datasource.dart';
import '../models/collection_model.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionLocalDataSource localDataSource;

  CollectionRepositoryImpl({required this.localDataSource});

  @override
  Future<int> addCollection(Collection collection) async {
    final model = CollectionModel.fromEntity(collection);
    return await localDataSource.addCollection(model);
  }

  @override
  Future<List<Collection>> getCollections({String? date, int? customerId}) async {
    return await localDataSource.getCollections(date: date, customerId: customerId);
  }

  @override
  Future<List<Collection>> getCollectionsByInvoice(int invoiceId) async {
    return await localDataSource.getCollectionsByInvoice(invoiceId);
  }

  @override
  Future<double> getTotalCollections({String? date}) async {
    return await localDataSource.getTotalCollections(date: date);
  }

  @override
  Future<double> getCustomerDebt(int customerId) async {
    return await localDataSource.getCustomerDebt(customerId);
  }

  @override
  Future<double> getTotalDebts() async {
    return await localDataSource.getTotalDebts();
  }
}
