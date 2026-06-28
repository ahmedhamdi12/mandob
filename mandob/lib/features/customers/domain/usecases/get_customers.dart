import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomers {
  final CustomerRepository repository;

  GetCustomers(this.repository);

  Future<List<Customer>> call({String query = ''}) {
    return repository.getCustomers(query: query);
  }
}
