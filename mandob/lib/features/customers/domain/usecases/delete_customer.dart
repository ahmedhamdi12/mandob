import '../repositories/customer_repository.dart';

class DeleteCustomer {
  final CustomerRepository repository;

  DeleteCustomer(this.repository);

  Future<int> call(int id) {
    return repository.deleteCustomer(id);
  }
}
