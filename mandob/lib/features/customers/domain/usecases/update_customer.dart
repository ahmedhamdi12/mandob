import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomer {
  final CustomerRepository repository;

  UpdateCustomer(this.repository);

  Future<int> call(Customer customer) {
    return repository.updateCustomer(customer);
  }
}
