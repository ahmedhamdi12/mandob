import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class AddCustomer {
  final CustomerRepository repository;

  AddCustomer(this.repository);

  Future<int> call(Customer customer) {
    return repository.addCustomer(customer);
  }
}
