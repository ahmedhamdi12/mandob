import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/cubit/customer_cubit.dart';
import '../../../customers/presentation/cubit/customer_state.dart';

class CustomerSelector extends StatefulWidget {
  final Customer? selectedCustomer;
  final ValueChanged<Customer> onCustomerSelected;

  const CustomerSelector({
    super.key,
    this.selectedCustomer,
    required this.onCustomerSelected,
  });

  @override
  State<CustomerSelector> createState() => _CustomerSelectorState();
}

class _CustomerSelectorState extends State<CustomerSelector> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().loadCustomers();
  }

  void _showCustomerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('اختر العميل', style: Theme.of(context).textTheme.titleLarge),
                ),
                Expanded(
                  child: BlocBuilder<CustomerCubit, CustomerState>(
                    builder: (context, state) {
                      if (state is CustomersLoaded) {
                        if (state.customers.isEmpty) {
                          return const Center(child: Text('لا يوجد عملاء متاحين'));
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: state.customers.length,
                          itemBuilder: (context, index) {
                            final customer = state.customers[index];
                            return ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(customer.name),
                              subtitle: customer.phone.isNotEmpty ? Text(customer.phone) : null,
                              onTap: () {
                                widget.onCustomerSelected(customer);
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(widget.selectedCustomer?.name ?? 'اضغط لاختيار العميل'),
        subtitle: widget.selectedCustomer != null ? const Text('تغيير العميل') : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: _showCustomerSheet,
      ),
    );
  }
}
