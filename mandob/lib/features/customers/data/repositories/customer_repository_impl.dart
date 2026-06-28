import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource localDataSource;

  CustomerRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Customer>> getCustomers({String query = ''}) async {
    return await localDataSource.getCustomers(query: query);
  }

  @override
  Future<Customer?> getCustomerById(int id) async {
    return await localDataSource.getCustomerById(id);
  }

  @override
  Future<int> addCustomer(Customer customer) async {
    final model = CustomerModel.fromEntity(customer);
    return await localDataSource.addCustomer(model);
  }

  @override
  Future<int> updateCustomer(Customer customer) async {
    final model = CustomerModel.fromEntity(customer);
    return await localDataSource.updateCustomer(model);
  }

  @override
  Future<int> deleteCustomer(int id) async {
    return await localDataSource.deleteCustomer(id);
  }
}
