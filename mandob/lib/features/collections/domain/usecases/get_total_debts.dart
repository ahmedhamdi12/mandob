import '../repositories/collection_repository.dart';

class GetTotalDebts {
  final CollectionRepository repository;

  GetTotalDebts(this.repository);

  Future<double> call() {
    return repository.getTotalDebts();
  }
}
