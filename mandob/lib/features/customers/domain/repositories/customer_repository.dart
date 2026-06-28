import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers({String query = ''});
  Future<Customer?> getCustomerById(int id);
  Future<int> addCustomer(Customer customer);
  Future<int> updateCustomer(Customer customer);
  Future<int> deleteCustomer(int id);
}
