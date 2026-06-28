import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/stock_purchase.dart';
import '../cubit/stock_cubit.dart';
import '../../../products/presentation/cubit/product_cubit.dart';
import '../../../products/presentation/cubit/product_state.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/utils/date_utils.dart';

class StockEntryForm extends StatefulWidget {
  const StockEntryForm({super.key});

  @override
  State<StockEntryForm> createState() => _StockEntryFormState();
}

class _StockEntryFormState extends State<StockEntryForm> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedProductId;
  final _qtyController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate() && _selectedProductId != null) {
      final purchase = StockPurchase(
        id: 0,
        productId: _selectedProductId!,
        qtyUnits: int.parse(_qtyController.text),
        costPerUnit: double.parse(_costController.text),
        purchaseDate: AppDateUtils.getCurrentIso(),
        notes: _notesController.text,
        createdAt: AppDateUtils.getCurrentIso(),
      );

      context.read<StockCubit>().addPurchase(purchase);
    } else if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المنتج'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              if (state is ProductsLoaded) {
                if (state.products.isEmpty) {
                  return const Text('لا يوجد منتجات، الرجاء إضافة منتجات أولاً', style: TextStyle(color: Colors.red));
                }
                return DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'المنتج'),
                  initialValue: _selectedProductId,
                  items: state.products.map((product) {
                    return DropdownMenuItem<int>(
                      value: product.id,
                      child: Text('${product.name} (${product.baseUnit})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProductId = val;
                    });
                  },
                  validator: (val) => val == null ? 'مطلوب' : null,
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _qtyController,
            decoration: const InputDecoration(
              labelText: 'الكمية (بالوحدة الصغرى للمنتج)',
              hintText: 'أدخل الكمية',
            ),
            keyboardType: TextInputType.number,
            validator: InputValidators.required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _costController,
            decoration: const InputDecoration(
              labelText: 'تكلفة الوحدة الصغرى',
              hintText: 'تكلفة الوحدة الواحدة',
            ),
            keyboardType: TextInputType.number,
            validator: InputValidators.required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'ملاحظات (اختياري)',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            child: const Text('حفظ في المخزون'),
          ),
        ],
      ),
    );
  }
}
