import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/get_customers.dart';
import '../../domain/usecases/add_customer.dart';
import '../../domain/usecases/update_customer.dart';
import '../../domain/usecases/delete_customer.dart';
import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final GetCustomers getCustomersUseCase;
  final AddCustomer addCustomerUseCase;
  final UpdateCustomer updateCustomerUseCase;
  final DeleteCustomer deleteCustomerUseCase;

  CustomerCubit({
    required this.getCustomersUseCase,
    required this.addCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
  }) : super(CustomerInitial());

  Future<void> loadCustomers({String query = ''}) async {
    emit(CustomerLoading());
    try {
      final customers = await getCustomersUseCase(query: query);
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> addCustomer(Customer customer) async {
    emit(CustomerLoading());
    try {
      await addCustomerUseCase(customer);
      emit(const CustomerOperationSuccess('تم إضافة العميل بنجاح'));
      loadCustomers();
    } catch (e) {
      emit(CustomerError(e.toString()));
      loadCustomers();
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    emit(CustomerLoading());
    try {
      await updateCustomerUseCase(customer);
      emit(const CustomerOperationSuccess('تم تعديل العميل بنجاح'));
      loadCustomers();
    } catch (e) {
      emit(CustomerError(e.toString()));
      loadCustomers();
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await deleteCustomerUseCase(id);
      emit(const CustomerOperationSuccess('تم حذف العميل بنجاح'));
      loadCustomers();
    } catch (e) {
      emit(CustomerError(e.toString()));
      loadCustomers();
    }
  }
}
