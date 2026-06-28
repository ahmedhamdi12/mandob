import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/supplier_invoice_cubit.dart';
import '../cubit/supplier_invoice_state.dart';
import '../cubit/warehouse_cubit.dart';
import '../cubit/warehouse_state.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/supplier_invoice.dart';
import '../../domain/entities/supplier_invoice_item.dart';
import '../../../../core/utils/date_utils.dart';

class NewSupplierInvoiceScreen extends StatefulWidget {
  final bool isReturn;
  const NewSupplierInvoiceScreen({super.key, this.isReturn = false});

  @override
  State<NewSupplierInvoiceScreen> createState() => _NewSupplierInvoiceScreenState();
}

class _NewSupplierInvoiceScreenState extends State<NewSupplierInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _paidAmountController = TextEditingController(text: '0');
  
  Supplier? _selectedSupplier;

  @override
  void initState() {
    super.initState();
    _invoiceNumberController.text = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    final itemNameController = TextEditingController();
    final qtyController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة صنف'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: itemNameController, decoration: const InputDecoration(labelText: 'اسم الصنف', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الكمية', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر', border: OutlineInputBorder()))),
              ],
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final name = itemNameController.text;
              final qty = double.tryParse(qtyController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0;

              if (name.isNotEmpty && qty > 0 && price >= 0) {
                final item = SupplierInvoiceItem(
                  id: 0,
                  invoiceId: 0,
                  itemName: name,
                  qty: qty,
                  unitPrice: price,
                  lineTotal: qty * price,
                );
                context.read<SupplierInvoiceCubit>().addItem(item);
                Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة'),
          )
        ],
      ),
    );
  }

  void _saveInvoice(double totalAmount) {
    if (_formKey.currentState!.validate() && _selectedSupplier != null) {
      final paidAmount = double.tryParse(_paidAmountController.text) ?? 0;
      final remaining = totalAmount - paidAmount;

      final invoice = SupplierInvoice(
        id: 0,
        invoiceNumber: _invoiceNumberController.text,
        supplierId: _selectedSupplier!.id,
        type: widget.isReturn ? 'return' : 'purchase',
        invoiceDate: AppDateUtils.getCurrentIso(),
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        remaining: remaining,
        status: 'active',
        createdAt: AppDateUtils.getCurrentIso(),
      );

      context.read<SupplierInvoiceCubit>().createInvoice(invoice);
    } else if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار مورد')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isReturn ? 'فاتورة مرتجع لمورد' : 'فاتورة شراء من مورد')),
      body: BlocListener<SupplierInvoiceCubit, SupplierInvoiceState>(
        listener: (context, state) {
          if (state is SupplierInvoiceSuccess) {
            context.read<WarehouseCubit>().loadData();
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح')));
          } else if (state is SupplierInvoiceError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSupplierDropdown(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _invoiceNumberController,
                  decoration: const InputDecoration(labelText: 'رقم الفاتورة', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildItemsList()),
                _buildTotalsAndSave(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierDropdown() {
    return BlocBuilder<WarehouseCubit, WarehouseState>(
      builder: (context, state) {
        if (state is WarehouseLoaded) {
          return DropdownButtonFormField<Supplier>(
            decoration: const InputDecoration(labelText: 'المورد', border: OutlineInputBorder()),
            initialValue: _selectedSupplier,
            items: state.suppliers.map((s) => DropdownMenuItem<Supplier>(value: s, child: Text(s.name))).toList(),
            onChanged: (val) => setState(() => _selectedSupplier = val),
            validator: (val) => val == null ? 'الرجاء اختيار مورد' : null,
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildItemsList() {
    return BlocBuilder<SupplierInvoiceCubit, SupplierInvoiceState>(
      builder: (context, state) {
        List<SupplierInvoiceItem> items = [];
        if (state is SupplierInvoiceItemAdded) items = state.items;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الأصناف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(onPressed: _showAddItemDialog, icon: const Icon(Icons.add), label: const Text('إضافة صنف')),
              ],
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('لم يتم إضافة أصناف'))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.itemName),
                          subtitle: Text('${item.qty} x ${item.unitPrice} ج.م'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${item.lineTotal} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => context.read<SupplierInvoiceCubit>().removeItem(index),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalsAndSave() {
    return BlocBuilder<SupplierInvoiceCubit, SupplierInvoiceState>(
      builder: (context, state) {
        double total = 0;
        if (state is SupplierInvoiceItemAdded) total = state.totalAmount;

        return Card(
          margin: const EdgeInsets.only(top: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الإجمالي:'), Text('$total ج.م', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paidAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المبلغ المدفوع', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _saveInvoice(total),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: widget.isReturn ? Colors.red : Colors.blue),
                  child: Text(widget.isReturn ? 'حفظ المرتجع' : 'حفظ الفاتورة'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
