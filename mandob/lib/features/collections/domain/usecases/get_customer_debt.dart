import '../repositories/collection_repository.dart';

class GetCustomerDebt {
  final CollectionRepository repository;

  GetCustomerDebt(this.repository);

  Future<double> call(int customerId) {
    return repository.getCustomerDebt(customerId);
  }
}
