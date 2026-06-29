import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/warehouse_cubit.dart';
import '../cubit/warehouse_state.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/supplier_payment.dart';

class WarehouseHomeScreen extends StatefulWidget {
  const WarehouseHomeScreen({super.key});

  @override
  State<WarehouseHomeScreen> createState() => _WarehouseHomeScreenState();
}

class _WarehouseHomeScreenState extends State<WarehouseHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<WarehouseCubit>().loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المخازن والموردين'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الموردين'),
            Tab(text: 'الفواتير'),
            Tab(text: 'المدفوعات'),
          ],
        ),
      ),
      body: BlocBuilder<WarehouseCubit, WarehouseState>(
        builder: (context, state) {
          if (state is WarehouseLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WarehouseError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          if (state is WarehouseLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildSuppliersTab(state.suppliers, state.totalDebt),
                _buildInvoicesTab(state.invoices),
                _buildPaymentsTab(state.payments),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            context.push('/warehouses/suppliers/add');
          } else if (_tabController.index == 1) {
            _showNewInvoiceOptions(context);
          } else if (_tabController.index == 2) {
             final state = context.read<WarehouseCubit>().state;
             if (state is WarehouseLoaded) {
               _showNewPaymentDialog(context, state.suppliers);
             }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNewInvoiceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.blue),
              title: const Text('فاتورة شراء جديدة'),
              onTap: () {
                Navigator.pop(context);
                context.push('/warehouses/invoices/new');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_return, color: Colors.red),
              title: const Text('فاتورة مرتجع جديدة'),
              onTap: () {
                Navigator.pop(context);
                context.push('/warehouses/invoices/new-return');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewPaymentDialog(BuildContext context, List<dynamic> suppliers) {
    int? selectedSupplierId;
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('تسجيل دفعة لمورد'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'المورد', border: OutlineInputBorder()),
                    initialValue: selectedSupplierId,
                    items: suppliers.map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (val) => setState(() => selectedSupplierId = val),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'المبلغ', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)', border: OutlineInputBorder()),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (selectedSupplierId != null && amount > 0) {
                      final payment = SupplierPayment(
                        id: 0,
                        supplierId: selectedSupplierId!,
                        amount: amount,
                        paymentDate: AppDateUtils.getCurrentIso(),
                        notes: notesController.text.isNotEmpty ? notesController.text : null,
                        createdAt: AppDateUtils.getCurrentIso(),
                      );
                      context.read<WarehouseCubit>().addPayment(payment);
                      Navigator.pop(dialogContext);
                    } else if (selectedSupplierId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار مورد')));
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSuppliersTab(List<dynamic> suppliers, double totalDebt) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إجمالي الديون للموردين:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('$totalDebt ج.م', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return ListTile(
                title: Text(supplier.name),
                subtitle: Text(supplier.phone ?? ''),
                trailing: Text('${supplier.currentBalance} ج.م', 
                  style: TextStyle(
                    color: supplier.currentBalance > 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold
                  )),
                onTap: () => context.push('/warehouses/suppliers/${supplier.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInvoicesTab(List<dynamic> invoices) {
    return ListView.builder(
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        final isPurchase = invoice.type == 'purchase';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: Icon(
              isPurchase ? Icons.shopping_cart : Icons.assignment_return,
              color: isPurchase ? Colors.blue : Colors.red,
            ),
            title: Text('${invoice.supplierName} - ${invoice.invoiceNumber}'),
            subtitle: Text(AppDateUtils.formatToDate(invoice.invoiceDate)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${invoice.totalAmount} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  invoice.status == 'cancelled' ? 'ملغاة' : (isPurchase ? 'شراء' : 'مرتجع'),
                  style: TextStyle(
                    color: invoice.status == 'cancelled' ? Colors.grey : (isPurchase ? Colors.blue : Colors.red),
                    fontSize: 12
                  )
                ),
              ],
            ),
            onTap: () => context.push('/warehouses/invoices/${invoice.id}'),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab(List<dynamic> payments) {
    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return ListTile(
          leading: const Icon(Icons.payment, color: Colors.green),
          title: Text(payment.supplierName ?? 'غير معروف'),
          subtitle: Text(AppDateUtils.formatToDate(payment.paymentDate)),
          trailing: Text('${payment.amount} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        );
      },
    );
  }
}
