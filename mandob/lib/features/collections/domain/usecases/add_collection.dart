import '../entities/collection.dart';
import '../repositories/collection_repository.dart';

class AddCollection {
  final CollectionRepository repository;

  AddCollection(this.repository);

  Future<int> call(Collection collection) {
    return repository.addCollection(collection);
  }
}
