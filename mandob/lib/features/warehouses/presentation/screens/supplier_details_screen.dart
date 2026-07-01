import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/warehouse_cubit.dart';
import '../cubit/warehouse_state.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/supplier_payment.dart';

class SupplierDetailsScreen extends StatelessWidget {
  final int supplierId;
  
  const SupplierDetailsScreen({super.key, required this.supplierId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WarehouseCubit, WarehouseState>(
      builder: (context, state) {
        if (state is! WarehouseLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final matches = state.suppliers.where((s) => s.id == supplierId);
        final supplier = matches.isNotEmpty ? matches.first : null;
        if (supplier == null) {
          return const Scaffold(body: Center(child: Text('المورد غير موجود')));
        }

        final supplierInvoices = state.invoices.where((i) => i.supplierId == supplierId).toList();
        final supplierPayments = state.payments.where((p) => p.supplierId == supplierId).toList();

        return Scaffold(
          appBar: AppBar(title: Text(supplier.name)),
          body: Column(
            children: [
              _buildSummaryCard(supplier),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.green,
                        unselectedLabelColor: Colors.green,
                        tabs: [
                          Tab(text: 'الفواتير'),
                          Tab(text: 'المدفوعات'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildInvoicesList(supplierInvoices),
                            _buildPaymentsList(supplierPayments),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddPaymentDialog(context, supplier.id, supplier.currentBalance),
            icon: const Icon(Icons.payment),
            label: const Text('تسجيل دفعة'),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(dynamic supplier) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: supplier.currentBalance > 0 ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('الرصيد الحالي', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text(
              '${supplier.currentBalance} ج.م',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: supplier.currentBalance > 0 ? Colors.red : Colors.green
              ),
            ),
            if (supplier.phone != null && supplier.phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(supplier.phone),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesList(List<dynamic> invoices) {
    if (invoices.isEmpty) return const Center(child: Text('لا توجد فواتير'));
    
    return ListView.builder(
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        final isPurchase = invoice.type == 'purchase';
        return ListTile(
          leading: Icon(isPurchase ? Icons.shopping_cart : Icons.assignment_return, color: isPurchase ? Colors.blue : Colors.red),
          title: Text(invoice.invoiceNumber),
          subtitle: Text(AppDateUtils.formatToDate(invoice.invoiceDate)),
          trailing: Text('${invoice.totalAmount} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildPaymentsList(List<dynamic> payments) {
    if (payments.isEmpty) return const Center(child: Text('لا توجد مدفوعات'));
    
    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return ListTile(
          leading: const Icon(Icons.payment, color: Colors.green),
          title: Text('${payment.amount} ج.م'),
          subtitle: Text(AppDateUtils.formatToDate(payment.paymentDate)),
          trailing: payment.notes != null ? const Icon(Icons.note) : null,
        );
      },
    );
  }

  void _showAddPaymentDialog(BuildContext context, int supplierId, double currentBalance) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل دفعة لمورد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الرصيد المستحق: $currentBalance ج.م', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
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
              if (amount > 0) {
                final payment = SupplierPayment(
                  id: 0,
                  supplierId: supplierId,
                  amount: amount,
                  paymentDate: AppDateUtils.getCurrentIso(),
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                  createdAt: AppDateUtils.getCurrentIso(),
                );
                context.read<WarehouseCubit>().addPayment(payment);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
