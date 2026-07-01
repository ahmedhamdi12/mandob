import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/supplier_invoice_cubit.dart';
import '../cubit/supplier_invoice_state.dart';
import '../cubit/warehouse_cubit.dart';
import '../cubit/warehouse_state.dart';

import '../../domain/entities/supplier_invoice.dart';
import '../../domain/entities/supplier_invoice_item.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../sales/presentation/widgets/product_selector_sheet.dart';
import '../../../products/domain/entities/product.dart';

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
  
  int? _selectedSupplierId;

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

  void _showAddProductDialog(Product product) {
    final qtyController = TextEditingController();
    final priceController = TextEditingController();

    if (product.lastPurchasePrice != null && product.lastPurchasePrice! > 0) {
      priceController.text = product.lastPurchasePrice.toString();
    } else if (product.calculatedUnitCost > 0) {
      priceController.text = product.calculatedUnitCost.toString();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الكمية الحالية في المخزون: ${product.stockQty} ${product.baseUnit}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: qtyController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'الكمية (${product.baseUnit})', border: const OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر الوحدة', border: OutlineInputBorder()))),
              ],
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text) ?? 0;
              final price = double.tryParse(priceController.text) ?? 0;

              if (qty > 0 && price >= 0) {
                if (widget.isReturn && qty > product.stockQty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('لا يمكن إرجاع كمية أكبر من المخزون الحالي'), backgroundColor: Colors.red),
                  );
                  return;
                }

                final item = SupplierInvoiceItem(
                  id: 0,
                  invoiceId: 0,
                  productId: product.id,
                  qtyUnits: qty.toInt(),
                  itemName: product.name,
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
    if (_formKey.currentState!.validate() && _selectedSupplierId != null) {
      final paidAmount = double.tryParse(_paidAmountController.text) ?? 0;
      final remaining = totalAmount - paidAmount;

      final invoice = SupplierInvoice(
        id: 0,
        invoiceNumber: _invoiceNumberController.text,
        supplierId: _selectedSupplierId!,
        type: widget.isReturn ? 'return' : 'purchase',
        invoiceDate: AppDateUtils.getCurrentIso(),
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        remaining: remaining,
        status: 'active',
        createdAt: AppDateUtils.getCurrentIso(),
      );

      context.read<SupplierInvoiceCubit>().createInvoice(invoice);
    } else if (_selectedSupplierId == null) {
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
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
                _buildItemsList(),
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
          final isIdValid = _selectedSupplierId != null && state.suppliers.any((s) => s.id == _selectedSupplierId);
          return DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'المورد', border: OutlineInputBorder()),
            initialValue: isIdValid ? _selectedSupplierId : null,
            items: state.suppliers.map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.name))).toList(),
            onChanged: (val) => setState(() => _selectedSupplierId = val),
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
                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ProductSelectorSheet(
                        onProductSelected: (product) {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (mounted) _showAddProductDialog(product);
                          });
                        },
                      ),
                    );
                  }, 
                  icon: const Icon(Icons.add), 
                  label: const Text('إضافة صنف')
                ),
              ],
            ),
            items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('لم يتم إضافة أصناف')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
