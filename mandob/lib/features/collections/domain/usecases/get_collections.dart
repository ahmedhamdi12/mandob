import '../entities/collection.dart';
import '../repositories/collection_repository.dart';

class GetCollections {
  final CollectionRepository repository;

  GetCollections(this.repository);

  Future<List<Collection>> call({String? date, int? customerId}) {
    return repository.getCollections(date: date, customerId: customerId);
  }
}
