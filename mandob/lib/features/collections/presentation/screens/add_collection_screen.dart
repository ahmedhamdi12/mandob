import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/collection_cubit.dart';
import '../cubit/collection_state.dart';
import '../../domain/entities/collection.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../customers/presentation/cubit/customer_cubit.dart';
import '../../../customers/presentation/cubit/customer_state.dart';
import '../../../sales/presentation/cubit/invoice_cubit.dart';
import '../../../sales/presentation/cubit/invoice_state.dart';

class AddCollectionScreen extends StatefulWidget {
  const AddCollectionScreen({super.key});

  @override
  State<AddCollectionScreen> createState() => _AddCollectionScreenState();
}

class _AddCollectionScreenState extends State<AddCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedCustomerId;
  int? _selectedInvoiceId;

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().loadCustomers();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onCustomerSelected(int? customerId) {
    setState(() {
      _selectedCustomerId = customerId;
      _selectedInvoiceId = null;
    });
    if (customerId != null) {
      // Load invoices for this customer that have remaining > 0
      context.read<InvoiceCubit>().loadInvoices(customerId: customerId);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCustomerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اختر العميل أولاً'), backgroundColor: Colors.red),
        );
        return;
      }

      final collection = Collection(
        id: 0,
        customerId: _selectedCustomerId!,
        invoiceId: _selectedInvoiceId,
        amount: double.parse(_amountController.text),
        collectDate: AppDateUtils.getCurrentIso(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: AppDateUtils.getCurrentIso(),
      );

      context.read<CollectionCubit>().addCollection(collection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل تحصيل')),
      body: BlocConsumer<CollectionCubit, CollectionState>(
        listener: (context, state) {
          if (state is CollectionSuccess) {
            context.pop();
          }
        },
        builder: (context, state) {
          if (state is CollectionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Customer selector
                BlocBuilder<CustomerCubit, CustomerState>(
                  builder: (context, customerState) {
                    if (customerState is CustomersLoaded) {
                      return DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'العميل'),
                        initialValue: _selectedCustomerId,
                        items: customerState.customers
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ))
                            .toList(),
                        onChanged: _onCustomerSelected,
                        validator: (val) => val == null ? 'اختر العميل' : null,
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                ),
                const SizedBox(height: 16),

                // Invoice selector (optional, shows only for selected customer)
                if (_selectedCustomerId != null)
                  BlocBuilder<InvoiceCubit, InvoiceState>(
                    builder: (context, invoiceState) {
                      if (invoiceState is InvoicesLoaded) {
                        final unpaidInvoices = invoiceState.invoices
                            .where((inv) => inv.remaining > 0 && inv.status == 'active')
                            .toList();

                        if (unpaidInvoices.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'لا توجد فواتير غير مسددة لهذا العميل ✓',
                              style: TextStyle(color: AppColors.success),
                            ),
                          );
                        }

                        return DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'الفاتورة (اختياري)',
                            hintText: 'تحصيل عام بدون فاتورة',
                          ),
                          initialValue: _selectedInvoiceId,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('تحصيل عام بدون فاتورة'),
                            ),
                            ...unpaidInvoices.map((inv) => DropdownMenuItem(
                                  value: inv.id,
                                  child: Text(
                                    '${inv.invoiceNumber} — متبقي: ${NumberUtils.formatCurrency(inv.remaining)}',
                                  ),
                                )),
                          ],
                          onChanged: (val) {
                            setState(() => _selectedInvoiceId = val);
                          },
                        );
                      }
                      return const LinearProgressIndicator();
                    },
                  ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'المبلغ المحصل'),
                  keyboardType: TextInputType.number,
                  validator: InputValidators.required,
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _save,
                  child: const Text('حفظ التحصيل'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
