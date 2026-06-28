import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';
import '../widgets/customer_card.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العملاء'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              context.push('/customers/add');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          AppSearchBar(
            hintText: 'ابحث بالاسم أو رقم الهاتف...',
            onChanged: (query) {
              context.read<CustomerCubit>().loadCustomers(query: query);
            },
          ),
          Expanded(
            child: BlocConsumer<CustomerCubit, CustomerState>(
              listener: (context, state) {
                if (state is CustomerOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is CustomerError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const LoadingWidget();
                } else if (state is CustomersLoaded) {
                  if (state.customers.isEmpty) {
                    return const EmptyStateWidget(
                      iconData: Icons.people_outline,
                      message: 'لا يوجد عملاء',
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: state.customers.length,
                    itemBuilder: (context, index) {
                      final customer = state.customers[index];
                      return CustomerCard(
                        customer: customer,
                        onTap: () {
                          context.push('/customers/edit/${customer.id}');
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/customers/add');
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
