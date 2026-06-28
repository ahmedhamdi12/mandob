import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/new_invoice_cubit.dart';
import '../cubit/new_invoice_state.dart';
import '../widgets/customer_selector.dart';
import '../widgets/product_selector_sheet.dart';
import '../widgets/invoice_item_row.dart';
import '../widgets/payment_type_selector.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../products/domain/entities/product.dart';

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key});

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  final _paidAmountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddProductDialog(BuildContext context, Product product) async {
    final qtyController = TextEditingController();
    final priceController = TextEditingController();

    // Fetch last price if available
    final lastPrice = await context.read<NewInvoiceCubit>().fetchLastPrice(product.id);
    if (lastPrice != null) {
      priceController.text = lastPrice.toString();
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(product.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('المخزون المتاح: ${product.stockQty} ${product.baseUnit}'),
              const SizedBox(height: 16),
              TextField(
                controller: qtyController,
                decoration: InputDecoration(labelText: 'الكمية (${product.baseUnit})'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'سعر الوحدة'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                final qty = double.tryParse(qtyController.text) ?? 0;
                final price = double.tryParse(priceController.text) ?? 0;
                
                if (qty <= 0 || price <= 0) return;

                if (qty > product.stockQty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الكمية المطلوبة أكبر من المخزون المتاح!'), backgroundColor: Colors.red),
                  );
                  return;
                }

                context.read<NewInvoiceCubit>().addOrUpdateItem(
                  product: product,
                  displayQty: qty,
                  qtyUnits: qty.toInt(), // Simplifying assuming base unit only for now
                  unitPrice: price,
                );
                
                Navigator.pop(ctx);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فاتورة مبيعات جديدة'),
      ),
      body: BlocConsumer<NewInvoiceCubit, NewInvoiceState>(
        listener: (context, state) {
          if (state is NewInvoiceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
          } else if (state is NewInvoiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is NewInvoiceUpdated) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CustomerSelector(
                  selectedCustomer: state.selectedCustomer,
                  onCustomerSelected: (customer) {
                    context.read<NewInvoiceCubit>().setCustomer(customer);
                  },
                ),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الأصناف', style: Theme.of(context).textTheme.titleLarge),
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ProductSelectorSheet(
                            onProductSelected: (product) => _showAddProductDialog(context, product),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة صنف'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (state.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('لم يتم إضافة أصناف بعد')),
                  )
                else
                  ...state.items.map((item) => InvoiceItemRow(
                    item: item,
                    product: state.productsCache[item.productId]!,
                    onRemove: () => context.read<NewInvoiceCubit>().removeItem(item.productId),
                  )),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الإجمالي:', style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      NumberUtils.formatCurrency(state.totalAmount),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                PaymentTypeSelector(
                  selectedType: state.paymentType,
                  onChanged: (val) {
                    context.read<NewInvoiceCubit>().setPaymentType(val);
                    if (val == 'cash') {
                      _paidAmountController.text = state.totalAmount.toString();
                    } else {
                      _paidAmountController.text = '0';
                    }
                  },
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _paidAmountController,
                  decoration: const InputDecoration(labelText: 'المبلغ المدفوع'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () {
                    final paid = double.tryParse(_paidAmountController.text) ?? 0;
                    context.read<NewInvoiceCubit>().saveInvoice(
                      paidAmount: paid,
                      notes: _notesController.text,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('حفظ الفاتورة', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
